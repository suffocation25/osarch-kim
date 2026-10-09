# Lab 0 - Inventory your own machine

Pair: Kim (no partner assigned yet)    Driver first half: Kim
Machine: ASUS TUF F15 FX507ZV4
Date: 08.10.2026

## What I did
Ran the commands in PowerShell (as administrator) and saved the command and its output into evidence/. The graphical system information window was not used.

## Result
| What | Value | Where I got it |
|------|-------|----------------|
| CPU model | 12th Gen Intel(R) Core(TM) i7-12700H | Get-CimInstance Win32_Processor |
| Cores / threads | 14 / 20 | Get-CimInstance Win32_Processor |
| Total RAM | 15.6 GB | (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory |
| RAM modules | 2 (8 GB + 8 GB) | Get-CimInstance Win32_PhysicalMemory |
| RAM speed | 3200 MHz | Get-CimInstance Win32_PhysicalMemory |
| Disk model | NVMe WD PC SN560 SDDPNQE-1T00-1002 | Get-PhysicalDisk |
| Disk type | SSD, NVMe | Get-PhysicalDisk (MediaType, BusType) |
| Free space on C: | 294.6 GB free of 952.9 GB | Get-Volume -DriveLetter C |
| Firmware type | UEFI | Confirm-SecureBootUEFI |
| Firmware version, date | FX507ZV4.329, 2024-10-14 | Get-CimInstance Win32_BIOS |
| Virtualization | enabled (VirtualizationFirmwareEnabled=False, HypervisorPresent=True) | Win32_Processor.VirtualizationFirmwareEnabled, Win32_ComputerSystem.HypervisorPresent |

## What did not work the first time
1. git clone failed: "git is not recognized as the name of a cmdlet". Git was not installed on the laptop. I installed it with winget (Git.Git), reopened PowerShell and repeated the command.
2. PowerShell started as administrator opened in C:\WINDOWS\System32, and mkdir failed with "access denied". I changed to my home folder first and created the folders there.
3. cat could not find cpu.txt, memory.txt and the other files in evidence/ because they had not been created. I reran the collection with full paths instead of relative ones.

## Evidence
- [evidence/cpu.txt](evidence/cpu.txt) - CPU model, cores, threads
- [evidence/memory.txt](evidence/memory.txt) - memory modules, speed, total
- [evidence/disk.txt](evidence/disk.txt) - disk model, type, free space
- [evidence/firmware.txt](evidence/firmware.txt) - firmware type, version, date
- [evidence/virtualization.txt](evidence/virtualization.txt) - virtualization status
