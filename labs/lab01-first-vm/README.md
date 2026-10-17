# Lab 1 — Your first virtual machine

Pair: Kim Amir (worked alone)   Driver first half: Kim Amir
Machine: ASUS TUF F15 FX507ZV4 (Intel Core i7-12700H, 16 GB RAM, RTX 4060), Windows 11, guest Ubuntu Server 25.04
Date: 17.10.2026

## What I did
1. Installed VirtualBox 7.2.20. Licence: https://www.virtualbox.org/wiki/Licensing_FAQ (the VirtualBox base package is free software under GPL version 3).
2. Created VM KimAmirOSA25: 2 vCPU, 8 GB RAM, 25 GB dynamic disk, NAT.
3. Installed Ubuntu Server 25.04, took snapshot clean-install.
4. Broke it (option A): cat /etc/hostname, sudo rm /etc/hostname, cat /etc/hostname, sudo reboot, hostname
5. Rolled back to clean-install and checked: cat /etc/hostname, hostname

## Resource justification
My host (from Lab 0) has an Intel Core i7-12700H with 14 cores and 20 logical processors, 16 GB of RAM and about 280 GB of free disk. I gave the VM 2 vCPU, which is far below half of the host's cores, because Ubuntu Server only runs a few commands in this lab and the host needs the rest. I gave it 8 GB of the 16 GB: Windows and my other programs need the other half, and 8 GB is more than enough for Ubuntu Server. The disk is 25 GB, dynamically allocated, out of 280 GB free, so it only uses the space it really needs. The network is NAT because the VM only needs internet access.

## Result
The VM boots; the break-and-rollback cycle is shown in the evidence below.

## What did not work the first time
1. At first I gave the VM 14 vCPU, which is all the physical cores of my laptop and more than the lab's rule of thumb (at most half of the cores). I changed it to 2 vCPU before taking the snapshot.
2. VirtualBox is in Russian and I could not find the snapshots at first. They are under the menu icon next to the VM name, in the "Снимки" (Snapshots) tab.

## Evidence
- [evidence/vm-settings.png](evidence/vm-settings.png) — CPU, memory and disk as configured
- [evidence/guest-release.png](evidence/guest-release.png) — Ubuntu Server is running in the guest
- [evidence/broken.png](evidence/broken.png) — the guest in its broken state
- [evidence/snapshot-list.png](evidence/snapshot-list.png) — the snapshot, after the rollback
