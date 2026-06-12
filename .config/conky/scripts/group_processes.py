#!/usr/bin/env python3
import subprocess
import sys

def get_processes():
    try:
        output = subprocess.check_output(["ps", "-eo", "comm,pcpu,rss", "--no-headers"], text=True)
    except Exception as e:
        return []
    
    processes = []
    for line in output.strip().split('\n'):
        parts = line.split()
        if len(parts) >= 3:
            rss = parts[-1]
            pcpu = parts[-2]
            comm = " ".join(parts[:-2])
            try:
                processes.append((comm, float(pcpu), int(rss)))
            except ValueError:
                continue
    return processes

def format_mem(kib):
    if kib >= 1048576:
        return f"{kib / 1048576:.1f}G"
    elif kib >= 1024:
        return f"{kib / 1024:.0f}M"
    else:
        return f"{kib}K"

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "cpu"
    processes = get_processes()
    if not processes:
        print("No processes found")
        return

    # Group by name
    grouped = {}
    for comm, pcpu, rss in processes:
        # Strip path if any (in case of absolute paths)
        comm = comm.split('/')[-1]
        if comm in grouped:
            grouped[comm]['cpu'] += pcpu
            grouped[comm]['mem'] += rss
            grouped[comm]['count'] += 1
        else:
            grouped[comm] = {'cpu': pcpu, 'mem': rss, 'count': 1}

    if mode == "cpu":
        # Sort by CPU
        sorted_proc = sorted(grouped.items(), key=lambda x: x[1]['cpu'], reverse=True)
        # Header
        print(f"${{color1}}{'PROCESS':<13}  {'CPU%':>5}  {'COUNT':>4}${{color}}")
        for comm, data in sorted_proc[:4]:
            name = comm[:13]
            print(f"{name:<13}  {data['cpu']:>4.1f}%  {data['count']:>4}")
    elif mode == "mem":
        # Sort by MEM
        sorted_proc = sorted(grouped.items(), key=lambda x: x[1]['mem'], reverse=True)
        # Header
        print(f"${{color1}}{'PROCESS':<13}  {'MEM':>5}  {'COUNT':>4}${{color}}")
        for comm, data in sorted_proc[:4]:
            name = comm[:13]
            mem_str = format_mem(data['mem'])
            print(f"{name:<13}  {mem_str:>5}  {data['count']:>4}")

if __name__ == "__main__":
    main()
