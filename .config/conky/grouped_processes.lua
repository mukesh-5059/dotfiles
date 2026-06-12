-- Conky Sidebar Helper Script (Lua)
-- Handles rounded card background drawing and process grouping by lineage

require 'cairo'
require 'cairo_xlib'

local wallpaper_bg = "#1D191B"

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
    ["systemd"] = true,
    ["init"] = true,
    ["kthreadd"] = true,
    ["bash"] = true,
    ["zsh"] = true,
    ["fish"] = true,
    ["sh"] = true,
    ["dash"] = true,
    ["tmux"] = true,
    ["tmux: client"] = true,
    ["tmux: server"] = true,
    ["screen"] = true,
    ["gnome-shell"] = true,
    ["plasma-shell"] = true,
    ["kwin"] = true,
    ["kwin_wayland"] = true,
    ["sway"] = true,
    ["hyprland"] = true,
    ["i3"] = true,
    ["lightdm"] = true,
    ["gdm"] = true,
    ["gdm-session-wor"] = true,
    ["sddm"] = true,
    ["xfce4-session"] = true,
    ["gnome-session-b"] = true,
    ["gnome-terminal-"] = true,
    ["konsole"] = true,
    ["xfce4-terminal"] = true,
    ["kitty"] = true,
    ["alacritty"] = true,
    ["wezterm"] = true,
    ["foot"] = true,
    ["xterm"] = true,
    ["urxvt"] = true,
}

-- CPU Core Count and Sampling Cache
local num_cores = 1
local cached_processes = nil
local cached_pids = nil
local last_ps_time = 0
local PS_CACHE_DURATION = 1.9 -- Update interval is 2.0s, cache slightly under to match update tick

-- Store previous ticks for instantaneous CPU calculation
local prev_system_total = nil
local prev_proc_ticks = {}

-- 1. Read number of CPU cores once on load
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

-- 2. Reads total system CPU ticks from /proc/stat
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

-- 3. Reads process ticks (utime + stime) from /proc/[pid]/stat
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
    
    -- field 12 is utime, field 13 is stime (relative to the end of process name parenthesis)
    local utime = tonumber(fields[12]) or 0
    local stime = tonumber(fields[13]) or 0
    return utime + stime
end

-- 4. Draws a rounded background card matching the Eww widgets
function conky_draw_sidebar_background()
    if conky_window == nil then return end
    
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
                                         conky_window.visual, conky_window.width,
                                         conky_window.height)
    local cr = cairo_create(cs)
    
    local w = conky_window.width
    local h = conky_window.height
    local r = 12
    
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
    
    -- Color: mixed background matching Eww
    cairo_set_source_rgba(cr, bg_r, bg_g, bg_b, 1.0)
    cairo_fill(cr)
    
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- 5. Fetches processes and calculates instantaneous CPU using /proc sampling
local function fetch_processes()
    local now = os.time()
    if cached_processes and (now - last_ps_time < PS_CACHE_DURATION) then
        return cached_processes, cached_pids
    end

    -- Run ps to get active process structure (much faster without pcpu avg calculation)
    local handle = io.popen("ps -eo pid,ppid,rss,comm --no-headers")
    if not handle then return nil, nil end

    local current_system_total = get_system_ticks()
    local processes = {}
    local pids = {}
    local next_proc_ticks = {}

    for line in handle:lines() do
        local pid_str, ppid_str, rss_str, name = line:match("^%s*(%d+)%s+(%d+)%s+(%d+)%s+(.+)$")
        if pid_str then
            local pid = tonumber(pid_str)
            local ppid = tonumber(ppid_str)
            local rss = tonumber(rss_str) or 0
            
            -- Read current CPU ticks for this PID
            local ticks = get_process_ticks(pid) or 0
            next_proc_ticks[pid] = ticks
            
            -- Calculate instantaneous CPU usage percentage
            local cpu = 0.0
            if prev_system_total and current_system_total and current_system_total > prev_system_total then
                local prev_ticks = prev_proc_ticks[pid] or 0
                local system_diff = current_system_total - prev_system_total
                local proc_diff = ticks - prev_ticks
                if proc_diff > 0 and system_diff > 0 then
                    cpu = (proc_diff / system_diff) * 100.0
                end
            end

            processes[pid] = {
                pid = pid,
                ppid = ppid,
                name = name,
                cpu = cpu,
                rss = rss
            }
            table.insert(pids, pid)
        end
    end
    handle:close()

    -- Save ticks for the next sample
    prev_system_total = current_system_total
    prev_proc_ticks = next_proc_ticks

    cached_processes = processes
    cached_pids = pids
    last_ps_time = now
    return processes, pids
end

-- 6. Groups processes by lineage and formats their CPU/memory output
function conky_get_grouped_processes(sort_by, limit)
    sort_by = sort_by or "cpu"
    limit = tonumber(limit) or 4

    local processes, pids = fetch_processes()
    if not processes then return "Error reading processes" end

    local groups = {}

    local function get_group_name(pid)
        local visited = {}
        local current = processes[pid]
        
        while current do
            if visited[current.pid] then
                return current.name
            end
            visited[current.pid] = true

            if system_processes[current.name] or current.ppid <= 1 then
                return current.name
            end

            local parent = processes[current.ppid]
            if not parent then
                return current.name
            end

            if system_processes[parent.name] then
                return current.name
            end

            current = parent
        end
        return "unknown"
    end

    for _, pid in ipairs(pids) do
        local proc = processes[pid]
        local group_name = get_group_name(pid)
        group_name = group_name:match("([^/]+)$") or group_name

        if not groups[group_name] then
            groups[group_name] = {
                name = group_name,
                cpu = 0.0,
                rss = 0
            }
        end
        groups[group_name].cpu = groups[group_name].cpu + proc.cpu
        groups[group_name].rss = groups[group_name].rss + proc.rss
    end

    local group_list = {}
    for _, group in pairs(groups) do
        table.insert(group_list, group)
    end

    if sort_by == "cpu" then
        table.sort(group_list, function(a, b) return a.cpu > b.cpu end)
    else
        table.sort(group_list, function(a, b) return a.rss > b.rss end)
    end

    local function format_mem(kib)
        if kib >= 1024 * 1024 then
            return string.format("%.2f GiB", kib / (1024 * 1024))
        elseif kib >= 1024 then
            return string.format("%.1f MiB", kib / 1024)
        else
            return string.format("%d KiB", kib)
        end
    end

    local lines = {}
    for i = 1, math.min(#group_list, limit) do
        local g = group_list[i]
        local name = g.name
        if #name > 12 then
            name = string.sub(name, 1, 11) .. "…"
        end
        local cpu_str = string.format("%5.1f%%", g.cpu)
        local mem_str = format_mem(g.rss)
        local line_str = string.format("${goto 16}%s${goto 112}%s${alignr}%s  ", name, cpu_str, mem_str)
        table.insert(lines, line_str)
    end

    local result = table.concat(lines, "\n")
    if conky_parse then
        return conky_parse(result)
    else
        return result
    end
end
