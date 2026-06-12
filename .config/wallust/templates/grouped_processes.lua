-- Conky Sidebar Helper Script (Lua)
-- Handles rounded card background drawing and process grouping by lineage

require 'cairo'
require 'cairo_xlib'

local wallpaper_bg = "{{background}}"

local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)) / 255,
           tonumber("0x" .. hex:sub(3, 4)) / 255,
           tonumber("0x" .. hex:sub(5, 6)) / 255
end

-- Mix background color with black at 25% weight (matching Eww background)
local bg_r, bg_g, bg_b = hex_to_rgb(wallpaper_bg)
bg_r, bg_g, bg_b = bg_r * 0.25, bg_g * 0.25, bg_b * 0.25

local system_processes = {
    ["Hyprland"] = true,
    ["agetty"] = true,
    ["alacritty"] = true,
    ["bash"] = true,
    ["dash"] = true,
    ["dbus-broker"] = true,
    ["dbus-daemon"] = true,
    ["fish"] = true,
    ["foot"] = true,
    ["gdm"] = true,
    ["gdm-session-wor"] = true,
    ["gnome-session-b"] = true,
    ["gnome-shell"] = true,
    ["gnome-terminal-"] = true,
    ["hyprland"] = true,
    ["i3"] = true,
    ["init"] = true,
    ["kitty"] = true,
    ["konsole"] = true,
    ["kthreadd"] = true,
    ["kwin"] = true,
    ["kwin_wayland"] = true,
    ["lightdm"] = true,
    ["login"] = true,
    ["plasma-shell"] = true,
    ["screen"] = true,
    ["sddm"] = true,
    ["sh"] = true,
    ["start-hyprland"] = true,
    ["sway"] = true,
    ["systemd"] = true,
    ["systemd-logind"] = true,
    ["tmux"] = true,
    ["tmux: client"] = true,
    ["tmux: server"] = true,
    ["urxvt"] = true,
    ["wezterm"] = true,
    ["xfce4-session"] = true,
    ["xfce4-terminal"] = true,
    ["xterm"] = true,
    ["zsh"] = true,
}

-- CPU/GPU Sampling Cache
local num_cores = 1
local cached_processes = nil
local cached_pids = nil
local last_ps_time = 0
local PS_CACHE_DURATION = 1.9 -- Update interval is 2.0s

-- Store previous ticks for instantaneous calculation
local prev_system_total = nil
local prev_proc_ticks = {}
local prev_gpu_ticks = {}
local last_sample_uptime = nil

-- 1. Get high-precision uptime for sample duration
local function get_uptime()
    local f = io.open("/proc/uptime", "r")
    if not f then return os.clock() end
    local line = f:read("*l")
    f:close()
    return tonumber(line:match("^(%d+%.%d+)"))
end

-- 2. Read number of CPU cores once on load
local function detect_cores()
    local f = io.open("/proc/cpuinfo", "r")
    if f then
        local content = f:read("*all")
        f:close()
        local _, count = content:gsub("processor%s+:", "")
        if count > 0 then
            num_cores = count
        end
    end
end
detect_cores()

-- 3. Reads total system CPU ticks from /proc/stat
local function get_system_ticks()
    local f = io.open("/proc/stat", "r")
    if not f then return nil end
    local line = f:read("*l")
    f:close()
    
    local user, nice, system, idle, iowait, irq, softirq, steal = line:match("^cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
    if user then
        return tonumber(user) + tonumber(nice) + tonumber(system) + tonumber(idle) +
               tonumber(iowait) + tonumber(irq) + tonumber(softirq) + tonumber(steal)
    end
    return nil
end

-- 4. Reads process ticks (utime + stime) from /proc/[pid]/stat
local function get_process_ticks(pid)
    local f = io.open("/proc/" .. pid .. "/stat", "r")
    if not f then return nil end
    local content = f:read("*all")
    f:close()
    
    local right_paren = content:find("%)")
    if not right_paren then return nil end
    
    local rest = content:sub(right_paren + 2)
    local fields = {}
    for field in rest:gmatch("%S+") do
        table.insert(fields, field)
    end
    
    local utime = tonumber(fields[12]) or 0
    local stime = tonumber(fields[13]) or 0
    return utime + stime
end

-- 5. Reads all unique GPU ticks and VRAM from /proc/*/fdinfo/*
local function get_gpu_stats()
    local gpu_map = {}
    local vram_map = {}
    local clients_seen = {}
    
    local handle = io.popen("grep -sH 'drm-engine-\\|drm-client-id\\|drm-memory-vram' /proc/*/fdinfo/* 2>/dev/null")
    if not handle then return gpu_map, vram_map end

    local temp_fd_data = {}

    for line in handle:lines() do
        -- Line format: /proc/PID/fdinfo/FD:KEY: VAL [ns|KiB]
        local pid_str, fd_str, key, val_str = line:match("/proc/(%d+)/fdinfo/(%d+):([%w%-]+):%s+(%d+)")
        if pid_str then
            local pid = tonumber(pid_str)
            local fd = tonumber(fd_str)
            local val = tonumber(val_str)
            
            local fd_key = pid .. ":" .. fd
            if not temp_fd_data[fd_key] then
                temp_fd_data[fd_key] = { pid = pid, engines = {}, client_id = nil, vram = 0 }
            end
            
            if key == "drm-client-id" then
                temp_fd_data[fd_key].client_id = val
            elseif key == "drm-memory-vram" then
                temp_fd_data[fd_key].vram = val
            elseif key:match("^drm%-engine%-") then
                temp_fd_data[fd_key].engines[key] = val
            end
        end
    end
    handle:close()

    for _, data in pairs(temp_fd_data) do
        local client_key = data.pid .. ":" .. (data.client_id or "no-id")
        if not clients_seen[client_key] then
            clients_seen[client_key] = true
            
            -- Aggregate Ticks
            local pid_ticks = 0
            for _, engine_val in pairs(data.engines) do
                pid_ticks = pid_ticks + engine_val
            end
            gpu_map[data.pid] = (gpu_map[data.pid] or 0) + pid_ticks
            
            -- Aggregate VRAM
            vram_map[data.pid] = (vram_map[data.pid] or 0) + data.vram
        end
    end

    return gpu_map, vram_map
end

-- 6. Draws a rounded background card
function conky_draw_sidebar_background()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
                                         conky_window.visual, conky_window.width,
                                         conky_window.height)
    local cr = cairo_create(cs)
    local w, h, r = conky_window.width, conky_window.height, 12
    
    cairo_move_to(cr, r, 0)
    cairo_line_to(cr, w - r, 0)
    cairo_curve_to(cr, w, 0, w, 0, w, r)
    cairo_line_to(cr, w, h - r)
    cairo_curve_to(cr, w, h, w, h, w - r, h)
    cairo_line_to(cr, r, h)
    cairo_curve_to(cr, 0, h, 0, h, 0, h - r)
    cairo_line_to(cr, 0, r)
    cairo_curve_to(cr, 0, 0, 0, 0, r, 0)
    cairo_close_path(cr)
    
    cairo_set_source_rgba(cr, bg_r, bg_g, bg_b, 1.0)
    cairo_fill(cr)
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- 7. Fetches processes and calculates CPU/GPU usage
local function fetch_processes()
    local now = os.time()
    local current_uptime = get_uptime()
    
    if cached_processes and (now - last_ps_time < PS_CACHE_DURATION) then
        return cached_processes, cached_pids
    end

    local handle = io.popen("ps -eo pid,ppid,rss,comm --no-headers")
    if not handle then return nil, nil end

    local current_system_total = get_system_ticks()
    local current_gpu_ticks, current_vram_usage = get_gpu_stats()
    
    local processes = {}
    local pids = {}
    local next_proc_ticks = {}
    
    local duration_sec = 0
    if last_sample_uptime then
        duration_sec = current_uptime - last_sample_uptime
    end

    for line in handle:lines() do
        local pid_str, ppid_str, rss_str, name = line:match("^%s*(%d+)%s+(%d+)%s+(%d+)%s+(.+)$")
        if pid_str then
            local pid = tonumber(pid_str)
            local ticks = get_process_ticks(pid) or 0
            next_proc_ticks[pid] = ticks
            
            local cpu = 0.0
            if prev_system_total and current_system_total and current_system_total > prev_system_total then
                local prev_ticks = prev_proc_ticks[pid] or 0
                local system_diff = current_system_total - prev_system_total
                local proc_diff = ticks - prev_ticks
                if proc_diff > 0 and system_diff > 0 then
                    cpu = (proc_diff / system_diff) * 100.0
                end
            end

            local gpu = 0.0
            if duration_sec > 0.05 then
                local current_gpu = current_gpu_ticks[pid] or 0
                local previous_gpu = prev_gpu_ticks[pid] or 0
                local gpu_diff_ns = current_gpu - previous_gpu
                if gpu_diff_ns > 0 then
                    gpu = (gpu_diff_ns / (duration_sec * 1000000000)) * 100.0
                end
                if gpu > 100 then gpu = 100 end
            end

            processes[pid] = {
                pid = pid, ppid = tonumber(ppid_str), name = name,
                cpu = cpu, gpu = gpu, vram = current_vram_usage[pid] or 0, rss = tonumber(rss_str) or 0
            }
            table.insert(pids, pid)
        end
    end
    handle:close()

    prev_system_total = current_system_total
    prev_proc_ticks = next_proc_ticks
    prev_gpu_ticks = current_gpu_ticks
    last_sample_uptime = current_uptime

    cached_processes = processes
    cached_pids = pids
    last_ps_time = now
    return processes, pids
end

-- 8. Groups processes and formats output
function conky_get_grouped_processes(sort_by, limit)
    sort_by = sort_by or "cpu"
    limit = tonumber(limit) or 4

    local processes, pids = fetch_processes()
    if not processes then return "Error" end

    local groups = {}
    local function get_group_name(pid)
        local visited, current = {}, processes[pid]
        while current do
            if visited[current.pid] then return current.name end
            visited[current.pid] = true
            if system_processes[current.name] or current.ppid <= 1 then return current.name end
            local parent = processes[current.ppid]
            if not parent or system_processes[parent.name] then return current.name end
            current = parent
        end
        return "unknown"
    end

    for _, pid in ipairs(pids) do
        local proc = processes[pid]
        local gname = get_group_name(pid):match("([^/]+)$") or "unknown"
        if not groups[gname] then groups[gname] = { name = gname, cpu = 0, gpu = 0, vram = 0, rss = 0 } end
        groups[gname].cpu = groups[gname].cpu + proc.cpu
        groups[gname].gpu = groups[gname].gpu + proc.gpu
        groups[gname].vram = groups[gname].vram + proc.vram
        groups[gname].rss = groups[gname].rss + proc.rss
    end

    local list = {}
    for _, g in pairs(groups) do table.insert(list, g) end
    table.sort(list, function(a, b) return (a[sort_by] or 0) > (b[sort_by] or 0) end)

    local function fmem(k)
        if k >= 1048576 then return string.format("%.1fG", k/1048576)
        elseif k >= 1024 then return string.format("%.0fM", k/1024)
        else return k.."K" end
    end

    local lines = {}
    for i = 1, math.min(#list, limit) do
        local g = list[i]
        local name = #g.name > 12 and g.name:sub(1,11).."…" or g.name
        local val = (sort_by == "rss") and fmem(g.rss) or string.format("%.1f%%", g[sort_by])
        local extra = (sort_by == "gpu") and fmem(g.vram) or fmem(g.rss)
        table.insert(lines, string.format("${goto 16}%-12s${goto 112}%7s${alignr}%5s  ", name, val, extra))
    end
    return conky_parse and conky_parse(table.concat(lines, "\n")) or table.concat(lines, "\n")
end
