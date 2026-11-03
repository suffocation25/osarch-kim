# Ticket 1 — New developer starts Monday, needs a test machine

## 1. What was asked

> Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks
>
> — Aigerim T. (Office Manager), subject: "test machine for new dev"

## 2. What was actually needed

**What the request left out, and what I assumed instead**

| Left out | What I would have asked Aigerim | What I assumed |
|---|---|---|
| Which operating systems. "Nothing special" does not say. | Which OS does he develop for? | Linux (Ubuntu Server) and Windows 11, because a developer has to try things on both, and the ticket brief asks for both. |
| For how long. The Windows 11 Enterprise evaluation is free but lasts about 90 days (Lab 2). | How long will the machine be used? | A few weeks to a few months. BUILD.md says what to do when the 90 days end (rebuild, or buy a licence). |
| Which computer the guests will run on. Windows 11 needs at least 4 GB of RAM, 64 GB of disk, TPM 2.0 and EFI. | What laptop does she have? | A laptop like mine: 16 GB RAM and at least 150 GB of free disk. BUILD.md states these minimums at the top. |
| Network. | Must the guests reach the internet? Must they see each other? | Both. That is why I use a NAT Network (see section 3). |
| Licence. Aigerim must not break a licence by mistake. | Is it for company use? | Yes, company use. VirtualBox itself is free (GPL v3), but its separate Extension Pack is free only for personal and evaluation use, so BUILD.md says not to install it. |

**Where the request is wrong or misleading**

- "Test computer": a physical computer is the wrong answer. A virtual machine protects the host, and "without breaking anything" is exactly what a snapshot gives: when he breaks the VM, it is restored to a clean state in a few minutes.
- "Nothing special": Windows 11 is not trivial in a VM. It needs EFI, Secure Boot and TPM 2.0. On my laptop the Windows guest also did not start with 2 vCPU (Lab 2).
- "Write down how to do it so I can do the next one myself": the deliverable is a document, not a finished machine. The reader is an office manager, not an IT person, so the document has to include how to check each step and how to roll back.

## 3. What I did

1. Used the two guests from Lab 1 and Lab 2 and measured the host. On 2026-11-03 at 12:20, with both VMs off, the host used 9.57 GiB of 15.64 GiB RAM (`evidence/00-host-resources.txt`).
2. Saved the real settings of both VMs with `VBoxManage showvminfo --machinereadable` (`evidence/vminfo-*.txt`) and the disk information with `VBoxManage list hdds` and `showmediuminfo` (`evidence/02-*.txt`), so that every number in this report comes from a file, not from memory.
3. Took the clean snapshots, checked the rollback, and collected the ping evidence from both guests.
4. Wrote `BUILD.md` and gave it to another person to follow (see below).

The Ubuntu guest now reports Ubuntu 26.04.1 LTS (`evidence/04-guest-uname.txt`). [[One sentence: did you install 26.04 directly, or upgrade from 25.04? Write what really happened.]]

**Settings that differ from the default**

("Default" is what the VirtualBox 7.2 New Virtual Machine wizard suggested after I chose the OS type.)

| Setting | Default | Mine | Why |
|---|---|---|---|
| Network (both guests) | NAT | NAT Network `LabNet`, 10.0.2.0/24, DHCP on | Plain NAT gives every VM its own private router, so the guests could not see each other. Host-only has no internet. Bridged can be rejected by campus networks. |
| Ubuntu vCPU | 1 | 2 | A server without a desktop needs little CPU. I chose 2 so that installs and updates do not run on a single core, and the host keeps the rest of its cores. |
| Ubuntu RAM | 2048 MB | 4096 MB | Gives the developer room for tools and builds. The server itself would run on 2 GB, so this is a comfort margin, not a requirement. |
| Windows vCPU | 2 | 8 | On my laptop the default 2 vCPU were not enough to start Windows. I raised it to 4, then to 8, and 8 worked (Lab 2). |
| Windows firmware, TPM, Secure Boot | set for the Windows 11 type in the wizard | EFI + Secure Boot + TPM 2.0 | Windows 11 refuses to install without them. I did not record which of these the wizard already enables by itself, so I list them here instead of claiming they differ. |

**Kept at the default, on purpose**

- Ubuntu disk 25 GB and Windows disk 80 GB, both **dynamically allocated** (not pre-allocated). The alternative, a fixed-size disk, is a little faster but takes the full 105 GB from the laptop immediately; dynamic disks take only what is used (about 6.5 GiB and 30 GiB today). Lab 2 README says the Windows disk is 64 GB; the real value, from `VBoxManage list hdds`, is 80 GB.
- Windows RAM 4096 MB, which is also Microsoft's minimum for Windows 11. More would not fit next to the Ubuntu guest on a 16 GB laptop (see the calculation below).

**Resources, calculated from my host**

- RAM: 15.64 GiB in total. With both VMs off, the host (Windows 11 and my open programs) already used 9.57 GiB, which leaves 6.07 GiB. The two guests together get 4 + 4 = 8 GiB, which is more than the 6.07 GiB that is free. So with all my programs open, both guests do not fit comfortably (in the Lab 2 overcommit test the host reached 94% RAM use). Rule: close other programs before starting both guests, or run one guest at a time.
- Disk: C: has 306 GiB free. The Ubuntu disk can grow to 25 GiB (about 6.5 GiB used today) and the Windows disk to 80 GiB (about 30 GiB used today). Worst case 105 GiB, which leaves about 200 GiB. Snapshots grow too, so I keep a margin.
- CPU: Ubuntu 2 + Windows 8 = 10 vCPU on a CPU with 14 cores and 20 threads (i7-12700H). This is more than half of the cores if both guests are busy at once, which is why I do not run both under load.

**Reader test.** [[Who followed BUILD.md (for example "a friend who is not on the course"), what they did, where they hesitated, what I changed. Same facts as in evidence/08-reader-test.md.]]

**What went wrong and how I solved it**

1. I tried to read the disk of the Windows VM with `VBoxManage showmediuminfo disk "C:\Users\Kanat\VirtualBox VMs\lab02-windows"` and got `VERR_ACCESS_DENIED`. The cause: I gave it the VM folder, but the command needs the disk file (or its UUID). I ran `VBoxManage list hdds` (`evidence/02-list-hdds.txt`), took the UUID of the disk and ran `showmediuminfo disk <UUID>`. This also showed that the Ubuntu VM runs on a differencing disk created by the snapshot, on top of the 25 GiB base disk.
2. The internet inside the guests was unstable. In the second run of the same ping test, Linux lost 75% of packets to 1.1.1.1 and Windows could not resolve example.com, while ping between the two guests stayed at 0% loss (`evidence/05b-second-run-unstable-internet.txt`). The first run was clean (`evidence/05-ping-between-guests.txt`). The ping between guests does not depend on the internet connection, so the guest network itself is fine; the unstable part is the outside connection.
3. In Lab 2 the Linux guest could not ping the Windows guest until I added a Windows Firewall rule for ICMPv4 echo requests. This is in BUILD.md, step 8.

## 4. Evidence

- `evidence/00-host-resources.txt` — host RAM and disk measured with both VMs off.
- `evidence/01-new-vm-wizard.png` — the new-VM wizard with the CPU, RAM and disk choices of the Windows VM.
- `evidence/02-disk-settings.png` — disk size and type of the Windows VM.
- `evidence/02-list-hdds.txt` — all virtual disks with capacity and format.
- `evidence/02-disk-info-*.txt` — "dynamic" format variant, capacity and size on disk of each disk.
- `evidence/03-network-adapter.png` — the network mode of a guest (NAT Network, LabNet).
- `evidence/04-guest-uname.txt` — the Linux guest: kernel, Ubuntu release and address 10.0.2.3, with the commands.
- `evidence/05-ping-between-guests.txt` — ping Linux to Windows, Windows to Linux, and both to the internet, unedited.
- `evidence/05b-second-run-unstable-internet.txt` — second run of the same test, with internet packet loss, unedited.
- `evidence/06-snapshot-list.png` and `evidence/06-snapshot-list-*.txt` — the clean snapshot of each VM.
- `evidence/07-rollback-check.txt` — a file created in the guest disappears after restoring the snapshot.
- `evidence/08-reader-test.md` — notes of another person following BUILD.md.
- `evidence/vminfo-*.txt` — full real settings of both VMs; every number in this report comes from here.

## 5. What I would do differently

- Save the settings of each VM to a file at the moment I finish each lab. While preparing this ticket I found that my Lab 1 and Lab 2 reports did not match the real VMs (Windows RAM 4 GB in the report against 8 GB in the VM, Windows disk 64 GB against 80 GB, Ubuntu 14 vCPU against the 2 I wrote), because I wrote numbers from memory.
- Ask Aigerim "how long is the machine needed?" first, because the 90-day limit of the Windows evaluation changes the whole answer.
- Give BUILD.md to another person before writing the report, not after, so the problems they find go into the document and not only into a note.
