# Builds for the new office

All four machines use the AM5 platform and DDR5 memory, so the memory and the CPU can be upgraded later. All prices are in KZT from one vendor, Shop.kz (Белый Ветер), taken on 2026-11-14 (see budget.csv and evidence/).

Memory prices are very high at the moment: a 32 GB DDR5-6000 kit costs 324,990 KZT and a 16 GB kit 159,990 KZT, so memory is the most expensive part of every machine. This is why I chose the memory size for each role carefully.

## Compatibility checks (as in Lab 3)
- Ryzen 5 7600X is socket AM5, 6 cores, 105 W, with integrated graphics. The MSI PRO B650M-P is AM5, micro-ATX, with 4 DDR5 slots, an M.2 slot and an HDMI output.
- Memory is DDR5 everywhere. The CPU officially supports DDR5-5200 (the 16 GB kit). The 32 GB kit is DDR5-6000, so the memory profile has to be switched on in BIOS, otherwise it runs slower.
- The Kingston NV3 is an NVMe M.2 (PCIe 4.0) SSD and fits the M.2 slot of the board.
- The ID-Cooling SE-214-XT Basic supports AM5 and 180 W, enough for the 7600X (up to about 140 W). It is about 150 mm high, and the case allows coolers up to 160 mm, so it fits.
- The Ocypus Gamma C50 case takes micro-ATX boards and has no power supply.
- The MSI MAG A650BN (650 W) has two 6+2 pin PCIe connectors, enough for the Gainward RTX 4060 Ti (about 160 W). The designer machine needs roughly 350 W at most, so 650 W is more than enough.
- Windows 11 needs TPM 2.0. On these AMD boards it is the firmware TPM (fTPM), which is switched on in BIOS.

## Build 1 - accountant

**Load:** accounting software and Excel all day, a browser and email, one or two windows open at a time. Needs Windows, because accounting software here usually requires it.
**Bottleneck:** not the CPU and not the graphics. What matters most is that the machine is reliable and the storage is fast enough, because it must not fail during reporting.
**Trade-off:** 16 GB of memory (the minimum), no graphics card and a small 23.8 in monitor (Qmax 24UM50HDM, 39,990 KZT). The CPU is the same Ryzen 5 7600X as in the other machines, which is more than this role needs, but it keeps all four machines on one platform.
**Alternative not taken:** 32 GB of memory (+165,000 KZT).
**Total:** 608,330 KZT

## Build 2 - sales manager

**Load:** CRM in a browser with 30-40 tabs, Excel and about four hours of video calls a day, often at the same time.
**Bottleneck:** memory, not the CPU. The CPU is mostly idle in this role, the memory is not.
**Trade-off:** I kept 16 GB. Memory prices are high now: a 32 GB kit costs 324,990 KZT and a 16 GB kit 159,990 KZT, so 32 GB would add 165,000 KZT. The board has four memory slots, so I can add another 2x8 GB kit later, when memory is cheaper, and get 32 GB without throwing anything away. The price of this choice is that the machine can run out of memory during a call with many tabs open.
**Alternative not taken:** 32 GB now.
**Total:** 608,330 KZT

## Build 3 - web developer

**Load:** code editor, Docker containers, a local database, sometimes a virtual machine, and many browser windows at once.
**Bottleneck:** memory first, then SSD speed. Containers and a virtual machine both want RAM at the same time.
**Trade-off:** 32 GB of memory (324,990 KZT) takes a big part of the money. To pay for it I chose Ubuntu (free and standard for development) instead of Windows, which saves 123,990 KZT. I also used the same 6-core Ryzen 5 7600X instead of a stronger CPU, no graphics card, one small monitor, and the same entry-level Kingston NV3 SSD (TLC, 1 TB) as the other machines.
**Alternative not taken:** a Ryzen 7, a second monitor and a faster SSD.
**Total:** 649,340 KZT

## Build 4 - designer

**Load:** large images and layouts in Photoshop or similar programs, work with colour, exporting files. Needs Windows for the usual design programs.
**Bottleneck:** the screen (colour and resolution) first, then memory for large files, then the graphics card.
**Trade-off:** the biggest part of the money went to the screen and to memory. The monitor is a Lenovo Legion 27Q-10 (135,990 KZT): 27 in IPS, 2560x1440 (QHD), colour gamut sRGB 99% and DCI-P3 90% according to the Shop.kz specification. It is the most expensive monitor of the four machines. I took it instead of the Full HD Philips 27E1N1100A/01 (58,990 KZT, sRGB 101.8%, DCI-P3 80%), because for design work QHD sharpness and the wider DCI-P3 coverage matter. Its 240 Hz is not needed for this job, it just comes with the model, and it is a gaming monitor, not a professional hardware-calibrated one. For the graphics card I took the RTX 4060 Ti (259,990 KZT) instead of the RTX 5060 (314,106 KZT on e-katalog.kz on 2026-11-13). By the G3D Mark score on chipversus.com the RTX 4060 Ti is even about 8.7% faster than the RTX 5060, and it is cheaper. The cost of this choice is that the card has only 8 GB of video memory, which can limit very heavy projects.
**Alternative not taken:** the cheaper Full HD Philips monitor (saves 77,000 KZT), a professional colour monitor and the RTX 5060.
**Total:** 1,129,320 KZT

## Budget

| Machine | KZT |
|---|---|
| Accountant | 608,330 |
| Sales | 608,330 |
| Web developer | 649,340 |
| Designer | 1,129,320 |
| **Total** | **2,995,320** |

Budget 3,000,000 KZT, left 4,680 KZT. Only a small reserve is left, so a price change of a few thousand tenge would bring the total over the budget. Keyboards, mice and cables are not included (see README, section 2).
