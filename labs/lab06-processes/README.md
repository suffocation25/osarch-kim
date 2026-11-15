# Lab 6 - Live processes and memory pressure

Pair: Kim Amir (solo) | Date: 15 Nov 2026

Guests: Ubuntu 26.04.1 LTS (kernel 7.0.0-38-generic, RAM 4096 MB, lowered to 2048 MB for Part 2) and Windows 11 (RAM 4096 MB).

Times: Linux logs are in UTC; Windows screenshots show Almaty time (UTC+5).

## Part 1 - One process, three tools


Process chosen: VBoxService (VirtualBox Guest Additions service). Why: it runs on both guests, so the same program can be looked at in Task Manager and Process Explorer (Windows guest) and in htop (Linux guest).

Screenshots (Almaty time): task-manager.png 16:39, htop.png 16:58, process-explorer.png 17:40 (both Windows screenshots show the same process, PID 2040).

| | Task Manager (Windows) | Process Explorer (Windows) | htop / ps (Linux) |
|---|---|---|---|
| PID | 2040 | 2040 | 1303 |
| Parent (name and PID) | - (not shown) | services.exe (684) | systemd (1) |
| "Memory" as shown by default | 1,084 K (Memory, private working set) | Private Bytes and Working Set | MEM% 0.2 (RES 5,852 K) |
| Private memory | Commit size 2,360 K | Private Bytes 2,432 K | - (no such column) |
| Working set / RES | Working set 9,160 K | Working Set 8,960 K | RES 5,852 K, SHR 4,772 K |
| Virtual size | - (not shown) | - (column not enabled) | VIRT 350M (VSZ 359,104 K from ps) |
| Handles / file descriptors | 196 | 196 | 8 (ls /proc/1303/fd) |
| Threads | 14 | 14 | 10 (NLWP from ps) |


Note: the Task Manager numbers were read at 16:39 and the Process Explorer numbers (Private Bytes, Working Set, handles, threads) from process-explorer.png at 17:40, so they differ by a few KB although it is the same process (PID 2040). I did not enable the WS Private column in Process Explorer; PowerShell at 16:31 gave: PID 2040, parent services (684), private working set 1,112 KB, working set 9,208 KB, private bytes 2,364 KB, virtual size 2,101,347 MB, 196 handles, 14 threads.

### Where the tools disagree
- "Memory" in Task Manager is the private working set (1,084 K). The working set of the same process is 9,160 K, so one process has two very different "memory" numbers on the same screen. htop's RES (5,852 K) also includes shared library pages, so it measures yet another thing.
- Commit size (Task Manager) is the same measure as Private Bytes (Process Explorer, PowerShell: 2,364 KB). htop has no column for it.
- Virtual size: about 2,101,347 MB (around 2 TB) on Windows versus 350 MB VIRT on Linux. It is reserved address space, not memory in use.
- Handles are not file descriptors: the 196 Windows handles include events, mutexes, registry keys and more, while the 8 Linux file descriptors are only files, sockets and pipes (/dev/vboxguest, /dev/urandom, two sockets, a pipe).
- Task Manager does not show the parent process at all; Process Explorer and htop/ps do.

## Part 2 - Memory pressure (Linux guest)


Guest RAM: 2048 MB (free shows 1.6Gi total). Swap: none at first (0B). Before the second run I added a temporary 1 GiB swapfile (fallocate, mkswap, swapon).

Setup: VirtualBox snapshot `before-lab6`, then RAM lowered from 4096 MB to 2048 MB, stress-ng installed, a script writes `free -h` every 3 seconds into memory-pressure.txt while stress-ng runs, and the kernel log is read afterwards with `journalctl -k -b`.

### Run 2 (with swap) - main result, evidence/memory-pressure.txt

Command: `stress-ng --vm 1 --vm-bytes 3000M --vm-keep --timeout 150s` inside `timeout 180` (3000 MB is more than RAM + swap, about 2.6 GB).

| | Before (12:44:12) | During (worst) | After (12:47:38) |
|---|---|---|---|
| Available | 1.3Gi | 6.0Mi (12:44:52) | 1.3Gi |
| Swap used | 0B of 1.0Gi | 1.0Gi of 1.0Gi (12:45:34) | 34Mi of 1.0Gi |

What happened (times in UTC):
- 12:44:21 stress-ng started. 4 seconds later (12:44:25) free was 58Mi, available 52Mi and swap already 117Mi used.
- Swap filled fast: 349Mi at 12:44:29, 634Mi at 12:44:33, 936Mi at 12:44:36.
- 12:44:37 the kernel killed the stress-ng worker for the first time. After a kill the memory was freed at once (for example available 1.3Gi and swap 24Mi at 12:44:47, available 1.1Gi at 12:44:58), then stress-ng started a new worker and memory filled again. That is why the numbers in the log go up and down like a saw. In total the kernel killed 9 workers (12:44:37, 12:44:48, 12:44:57, 12:45:03, 12:45:13, 12:45:21, 12:45:34, 12:45:48, 12:47:23).
- Responsiveness: the logging loop should write every 3 seconds, but there are no samples between 12:46:01 and 12:47:23 (1 min 22 s), so the guest was almost frozen. In the same period the kernel printed soft lockup warnings (`Tainted: [L]=SOFTLOCKUP`), `blk_mq_run_work_fn hogged CPU` and journald reported `Under memory pressure, flushing caches`.
- The run ended at 12:47:23. stress-ng reports "successful run completed in 3 mins 1.98 sec" although I asked for --timeout 150s: the starved system stopped it late (my safety timeout of 180 s fires at about the same moment). In stress.log stress-ng also says it wanted 2.93GB per worker while only 865.75MB was available.

### What the kernel did (evidence/kernel-log-extract.txt)
First kill:
`Nov 15 12:44:37 KimAmirOSA25 kernel: Out of memory: Killed process 2493 (stress-ng-vm) total-vm:2768756kB, anon-rss:1409952kB, file-rss:584kB, shmem-rss:0kB, UID:1000 pgtables:4856kB oom_score_adj:1000`
- Which process: stress-ng-vm, PID 2493, the memory worker started by stress-ng.
- Why this one: it held about 1.4 GB of anonymous memory (anon-rss) out of 1.6 GB of RAM, so it was by far the biggest, and its oom_score_adj is 1000, the highest value (stress-ng sets it so that the kernel kills it first and not system services).
- When: 12:44:37, 16 seconds after the start, one second after swap reached 936Mi in memory-pressure.txt (12:44:36), i.e. when RAM and swap were both almost full.
- The kernel also logged `__vm_enough_memory: ... bytes: 3145728000 not enough memory for the allocation`: it refused to give the new worker the 3 GB it asked for.

### Run 1 (without swap) - kept as evidence/memory-pressure-run1-noswap.txt, stress-run1.log
The guest had no swap at all (Swap 0B in every sample) and I started stress-ng with 70%, 90% and 120% of memory. stress-ng takes the percentage from the available memory at that moment (585 MB of 836 MB, 650 MB of 722 MB, 973 MB of 810 MB), so everything still fitted in 1.6 GiB of RAM and the kernel did not need the OOM killer (no "Out of memory" line in kernel-log-full.txt). The page cache was thrown away instead: buff/cache fell from 560-663Mi to 260Mi. Lowest available memory was 197Mi (12:17:55, used 1.4Gi, free 85Mi).

The guest was still almost unusable: runs that should last 60, 60 and 90 seconds took 2 min 56 s, 9 min 50 s and 4 min 50 s, the logging loop has gaps of 2 min 39 s (12:04:43 - 12:07:22), 9 min 32 s (12:07:51 - 12:17:23) and 4 min 24 s (12:17:59 - 12:22:23), and the host Task Manager showed the memory load for 7-8 minutes. At 12:17:23 the kernel warned that its RCU thread was starved of CPU time ("Unless rcu_preempt kthread gets sufficient CPU time, OOM is now expected behavior"). This is thrashing without swap: pages of programs and libraries are dropped and read from disk again and again.

### Windows

Command: `Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5 | Format-List TimeCreated, Id, Message`

Result: `Get-WinEvent : No events were found that match the specified selection criteria.` (NoMatchingEventsFound), run on the Windows guest on 15 Nov 2026.

Explanation: this guest never ran out of memory, so Windows wrote no such event. I would expect event ID 2004 (Resource-Exhaustion-Detector) when the commit charge gets close to its limit (RAM plus pagefile). It names the processes that used the most memory. Windows does not kill processes like the Linux OOM killer: it warns, new allocations fail, and then this event is written. The Linux counterpart is the "Out of memory: Killed process" line, and the `__vm_enough_memory ... not enough memory for the allocation` lines show the same thing, a refused allocation.

## What did not work the first time
- My helper function for running commands in Ubuntu failed with `cannot execute binary file` because the shell was passed twice (--exe and as the first argument); I removed --exe.
- My first process-explorer.png was a screenshot of a PowerShell window, not Process Explorer, so I took it again.
- The first memory run had no swap, so the swap figure stayed at 0B and kernel-log-extract.txt was empty. I added a 1 GiB swapfile and asked for 3000M, more than RAM plus swap; then the OOM killer worked.
- While the guest was frozen, `VBoxManage guestcontrol` answered `Error starting guest session (current status is: starting)`; I waited until the guest recovered.
- `VBoxManage guestcontrol copyfrom --target-directory` with several files failed (`Destination ... is a directory`); I copied the files one by one.

## Files
evidence/task-manager.png, evidence/process-explorer.png, evidence/htop.png, evidence/memory-pressure.txt, evidence/kernel-log-extract.txt (required); evidence/stress.log, evidence/memory-pressure-run1-noswap.txt, evidence/stress-run1.log, evidence/kernel-log-full.txt (extra, run 1 and the full kernel log).