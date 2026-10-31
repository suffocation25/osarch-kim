# Lab 2 — A Windows guest, and a network between them

Pair: Kim (worked alone)   Driver first half: Kim
Machine: ASUS TUF F15 FX507ZV4, Windows 11 host, Intel i7-12700H (14 cores), 16 GB RAM; VirtualBox 7.2.20; guests Ubuntu Server (KimAmirOSA25) + Windows 11 Enterprise eval (lab02-windows)
Date: 30.10.2026

## What I did

1. Downloaded the Windows 11 Enterprise evaluation ISO (x64, English (United States)).
   Licence: free evaluation, 90 days, no product key typed.
   Source: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise
2. Created lab02-windows in VirtualBox: 4 GB RAM, 64 GB thin disk, EFI + Secure Boot, TPM 2.0.
   vCPU: 8. I planned 2, but it did not work, see "What did not work the first time".
3. Installed Windows 11 and the VirtualBox Guest Additions.
4. Network mode: NAT Network "LabNet" (10.0.2.0/24, DHCP on), both guests.
   Why: both guests must see each other and the internet. Plain NAT in VirtualBox gives every VM
   its own private router, so the guests would not see each other. Host-only has no internet.
   Bridged mode can be blocked on campus Wi-Fi, so I did not use it.
5. Added a port forwarding rule in LabNet so the host can run commands on Ubuntu:
   name ssh, TCP, host 127.0.0.1:2222 -> guest 10.0.2.3:22.
6. Addresses: Ubuntu 10.0.2.3, Windows 10.0.2.4.
7. Ping Windows -> Ubuntu worked at once. Ping Ubuntu -> Windows timed out (100% packet loss),
   because Windows Defender Firewall blocks incoming ICMP echo requests by default.
   The network profile of the Windows guest is Public (Get-NetConnectionProfile).
   Fixed with one rule (PowerShell as Administrator), the firewall stays on:

```
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

8. Checked the rule. Enabled: True, Direction: Inbound, Action: Allow, Profile: Any.

```
Get-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" | Get-NetFirewallPortFilter
Protocol      : ICMPv4
IcmpType      : 8
```

9. After the rule, ping Ubuntu -> Windows: 4 packets sent, 4 received, 0% packet loss.
   Both guests also reach the internet (ping ubuntu.com from both).
10. Overcommitment: set 10 GB (Ubuntu) + 10 GB (Windows) = 20 GB on a 16 GB host.
11. Put the memory back: Ubuntu 4 GB, Windows 4 GB.

Commands I used to get the evidence:

```
ip -br a                                              (Ubuntu)
ipconfig                                              (Windows)
ssh -p 2222 amir@127.0.0.1 "ip addr"                  (from the host, through the port forwarding rule)
ssh -p 2222 amir@127.0.0.1 "ping -c 4 10.0.2.4"       (Ubuntu -> Windows)
ping 10.0.2.3                                         (Windows -> Ubuntu)
ping ubuntu.com                                       (internet, both guests)
```

## Network diagram

```
                 Internet
                    |
   Host laptop 10.228.107.33 (Wi-Fi)
        |  ssh: 127.0.0.1:2222 -> 10.0.2.3:22
        |
 [VirtualBox NAT Network "LabNet" · 10.0.2.0/24 · gateway 10.0.2.1]
          /                              \
KimAmirOSA25 (Ubuntu Server)        lab02-windows (Windows 11)
10.0.2.3                            10.0.2.4
```

## Result

Host: Windows Task Manager -> Performance -> Memory.

| | Before (both VMs off) | After (10 GB + 10 GB) |
|---|---|---|
| Host RAM in use | 7.1 GB (46%) | 14.7 GB (94%) |
| Available | 8.4 GB | 0.9 GB (lowest I saw: about 0.4 GB) |
| Committed | 10.4 of 25.6 GB | 31.4 of 32.8 GB |
| What I noticed | — | No lag on the host. The Windows VM did not start. |

Ubuntu with 10 GB started and took most of the free memory. Committed memory reached 31.4 of 32.8 GB,
so there was almost nothing left, and I think that is why the second 10 GB guest could not start.
The commit limit itself grew from 25.6 GB to 32.8 GB. So VirtualBox did not let me promise more than
the host could commit: instead of freezing, the second guest just refused to start.

## What did not work the first time

- 2 vCPU were not enough for the Windows VM to run. I raised it to 4, then to 8, and with 8 everything worked.
  8 is more than half of my 14 cores, but the smaller values did not work.
- At first the network adapter of lab02-windows was plain "NAT", and the Name field for the NAT Network
  was empty. After I changed "Attached to" to "NAT Network" and chose LabNet, it worked.
- SSH to Ubuntu did not work, because the ssh service was "inactive (dead)".
  I started it with `sudo systemctl enable --now ssh`.
- Ping Ubuntu -> Windows timed out. This is what I saw before the firewall rule:

```
$ ssh -p 2222 amir@127.0.0.1 "ping -c 4 10.0.2.4"
PING 10.0.2.4 (10.0.2.4) 56(84) bytes of data.

--- 10.0.2.4 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 4585ms
```

  It was the Windows firewall (ICMP echo is blocked by default). I added one rule for ICMPv4 type 8
  and did not switch the firewall off.
- In the overcommitment test the Windows VM with 10 GB did not start. I did not save the exact error text.

## Evidence

- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows address (10.0.2.4)
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Ubuntu address (10.0.2.3)
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — both directions and the internet
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host memory, guests off
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — host memory, 10 GB + 10 GB promised
