# Lab 4 - Partition, mirror, fail, recover

Pair: Kim Amir + worked alone - Date: 11 November 2026 - Hypervisor: VirtualBox 7.2.20

## Windows

Guest: Windows 11 (VM lab02-windows). A new 1 GB virtual disk (lab04-win) was added, initialised as GPT, partitioned and formatted as NTFS with drive letter E: and label LAB04.

Commands:

```powershell
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel LAB04
Get-Disk | Select Number, FriendlyName, PartitionStyle, Size
Get-Volume | Where FileSystemLabel -eq 'LAB04'
```

Output:

```
PS> Get-Disk | Select Number, FriendlyName, PartitionStyle, Size

Number FriendlyName  PartitionStyle        Size
------ ------------  --------------        ----
     0 VBOX HARDDISK GPT            85899345920
     1 VBOX HARDDISK GPT             1073741824


PS> Get-Volume | Where FileSystemLabel -eq 'LAB04'

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining       Size
----------- ------------ -------------- --------- ------------ ----------------- -------------       ----
E           LAB04        NTFS           Fixed     Healthy      OK                    987.73 MB 1007.93 MB
```

MBR or GPT: GPT. Windows 11 boots with UEFI, which uses GPT, and GPT keeps a backup copy of the partition table with checksums. MBR is limited to 2 TiB and four primary partitions, so it has no advantage for this disk.

## Linux - layout before and after

### Before

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME    SIZE TYPE FSTYPE   MOUNTPOINTS
loop0   1.5M loop squashfs /snap/hwctl/123
loop1  66.8M loop squashfs /snap/core24/1643
loop2   1.5M loop squashfs /snap/hwctl/131
loop3  50.1M loop squashfs /snap/snapd/27710
loop4  44.7M loop squashfs /snap/snapd/28254
sda      25G disk          
├─sda1    1M part          
└─sda2   25G part ext4     /
sdb       1G disk          
sdc       1G disk          
sdd       1G disk          
sr0    1024M rom
```

### After

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME     SIZE TYPE  FSTYPE            MOUNTPOINTS
loop0    1.5M loop  squashfs          /snap/hwctl/123
loop1   66.8M loop  squashfs          /snap/core24/1643
loop2    1.5M loop  squashfs          /snap/hwctl/131
loop3   50.1M loop  squashfs          /snap/snapd/27710
loop4   44.7M loop  squashfs          /snap/snapd/28254
sda       25G disk                    
├─sda1     1M part                    
└─sda2    25G part  ext4              /
sdb        1G disk                    
└─sdb1  1022M part  linux_raid_member 
  └─md0 1021M raid1 ext4              /mnt/mirror
sdc        1G disk                    
└─sdc1  1022M part  linux_raid_member 
sdd        1G disk                    
└─sdd1  1022M part  linux_raid_member 
  └─md0 1021M raid1 ext4              /mnt/mirror
sr0     1024M rom
```

## What I did

These commands were run inside the Ubuntu guest. I sent them from the host as one script with VBoxManage guestcontrol, and the script saved the state of the array and the checksums to evidence/ at the moment each of them happened. The three new 1 GB disks were sdb, sdc and sdd.

```bash
for d in sdb sdc sdd; do sudo parted -s /dev/$d mklabel gpt mkpart primary 1MiB 100% set 1 raid on; done
sudo mdadm --create /dev/md0 --run --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
sudo mdadm --wait /dev/md0
sudo mkfs.ext4 -q -L mirror /dev/md0
sudo mkdir -p /mnt/mirror; sudo mount /dev/md0 /mnt/mirror; sudo chown amir: /mnt/mirror
echo "Lab 4 proof file - Kim Amir - $(date)" > /mnt/mirror/proof.txt
head -c 20M /dev/urandom > /mnt/mirror/random.bin
cd /mnt/mirror; sha256sum proof.txt random.bin      # saved as checksum-before.txt
sudo mdadm /dev/md0 --fail /dev/sdc1
sudo mdadm /dev/md0 --remove /dev/sdc1
cat /proc/mdstat; sudo mdadm --detail /dev/md0      # saved as array-degraded.txt
sha256sum proof.txt random.bin                      # saved as checksum-after-failure.txt
sudo mdadm /dev/md0 --add /dev/sdd1
sudo mdadm --wait /dev/md0
cat /proc/mdstat; sudo mdadm --detail /dev/md0      # saved as array-rebuilt.txt
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

## Three states

| State | What /proc/mdstat showed | File |
| --- | --- | --- |
| Healthy | [2/2] [UU] | evidence/array-healthy.txt |
| Degraded | [2/1] [U_] | evidence/array-degraded.txt |
| Rebuilt | [2/2] [UU], sdd1 replaced sdc1 | evidence/array-rebuilt.txt |

Checksums before the failure:

```
$ sha256sum proof.txt random.bin
c1ef1e4ce2ef9e49dd7b22d784be72979c1d493b03b7090e7fc3a34fd25a8cb1  proof.txt
88688066ac9f628ac317e3d9a0c39f428710287c9ba3cb0c71f1f0428bbdeaa2  random.bin
```

Checksums after the failure:

```
$ sha256sum proof.txt random.bin
c1ef1e4ce2ef9e49dd7b22d784be72979c1d493b03b7090e7fc3a34fd25a8cb1  proof.txt
88688066ac9f628ac317e3d9a0c39f428710287c9ba3cb0c71f1f0428bbdeaa2  random.bin
```

Checksums before and after the failure: match

## RAID is not a backup

Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No, RAID 1 does not help, because a mirror copies every change to both disks immediately, including the deletion. RAID protects against the hardware failure of a disk, not against human error, corruption or malware. Only a backup kept separately and from an earlier point in time lets you get the deleted file back.

## What did not work the first time

The first thing that did not work was SSH from the host to the Ubuntu guest: ssh -p 2222 amir@127.0.0.1 gave connection refused, because host port 2222 was already used by an old NAT-network port-forwarding rule, so I could not add a new one. Instead of fixing the forwarding I installed virtualbox-guest-utils in the guest and ran every Linux command from the host with VBoxManage guestcontrol. That also failed at first: bash printed cannot execute binary file because I had passed an extra bash argument after --, and sudo said interactive authentication is required, so I added a temporary NOPASSWD sudoers rule (removed at the end). Finally, VBoxManage copyto did not put the script into the guest, so I sent the script as base64 and decoded it inside the guest.