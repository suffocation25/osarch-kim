# Ticket 2 - Kitting out the new office

## 1. What was asked

From Daniyar K. (Director): "We are opening the second office and need four computers - accountant, sales, web developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy the same four machines, is that right? Make sure they last a few years. Monitors included."

## 2. What was actually needed

Four identical machines are not the best choice. The four people do different work, so a different resource runs out first for each of them. The accountant needs reliability and Windows, the sales manager needs memory, the developer needs memory and fast storage, and the designer needs a good screen. If everyone gets the same machine, money is wasted where a resource is idle and missing where it is needed.

The request also left some things out:
- It says "monitors included", but nothing about the operating system, keyboards, mice, cables, a UPS or delivery. I put monitors and operating systems in the budget and did not include keyboards, mice and cables.
- "A few years" is not a number.
- It does not say which software each person uses.

What I would ask Daniyar:
- Which accounting software does the accountant use, and does it need Windows?
- Does the designer use programs that need a specific graphics card?
- Are keyboards, mice and a UPS part of the 3,000,000 tenge?
- How many years should the machines last?

What I assumed instead: the accountant, the sales manager and the designer need Windows, the developer can use Ubuntu, "a few years" means about 4-5 years, and keyboards and mice are bought separately from the money that is left.

## 3. What I did

I started from the four roles, wrote the load of each one, found the bottleneck and decided where to spend the money (see [builds.md](builds.md)). All machines use AM5 and DDR5, so the CPU and memory can be upgraded later. I took all prices from one vendor, Shop.kz (Белый Ветер), which delivers all over Kazakhstan: this gives one order, one invoice and one warranty contact for the whole office. Every part is listed with price, source and date in [budget.csv](budget.csv). The total is 2,995,320 KZT, which is under the 3,000,000 KZT budget, but only by 4,680 KZT.

Memory prices are very high now (a 32 GB DDR5-6000 kit is 324,990 KZT, a 16 GB kit is 159,990 KZT). Because of this the sales manager got 16 GB and not 32 GB: the decision was made with a future upgrade in mind, since the board has four memory slots and a second 2x8 GB kit can be added when memory becomes cheaper.

**Which machine will I upgrade first, in eighteen months?**
The sales manager's machine, and the part is the memory. It has 16 GB now, and I will add a second 2x8 GB kit (the board has four slots) to get 32 GB, when memory prices are lower. It is the cheapest and most useful upgrade, because memory is exactly the resource this role runs out of, and it needs no other parts to be changed. It may even happen earlier than eighteen months.

**Pre-built machines.**
I looked for pre-built PCs on alfa.kz (prices of Almaty stores, seen 2026-11-14; they must be checked again with screenshots). Pre-built prices usually do not include a monitor, so I compare with my builds without the monitor.

| Role | Pre-built model | Main parameters | Price, KZT | Store | My build without monitor, KZT |
|---|---|---|---|---|---|
| Accountant | Dell Pro Tower QCT1255 (210-BQNH) | Ryzen 5 8600G, 16 GB DDR5, **512 GB** SSD, Windows 11 Pro | 425,450 | Tayfi (alfa.kz) | 568,340 |
| Sales | HP ProDesk 4 Tower G1i (9H7V0ET) | Intel Core Ultra 7 265 (20 cores, integrated graphics), 32 GB DDR5, 1 TB SSD, Windows 11 Pro, keyboard and mouse included | 1,091,475 | alfa.kz | 568,340 (16 GB) |
| Web developer | HP ProDesk 4 Tower G1i (9H7V0ET) (same model as for sales) | same as above | 1,091,475 | alfa.kz | 609,350 (with Ubuntu) |
| Designer | PULSER Advanced 435 | Ryzen 5 7500F, 32 GB DDR5, 1 TB SSD, RTX 5060, 600 W PSU, no OS listed | 883,707 | Vendara (alfa.kz) | 993,330 (with RTX 4060 Ti and Windows) |

Only the HP matches 32 GB DDR5, a 1 TB SSD and integrated graphics, and I did not find other pre-built machines with 32 GB that are similar to mine, so the same HP is used for both the sales manager and the web developer. The Dell and the PULSER prices are from the alfa.kz listing https://alfa.kz/pc/computers/amd/ryzen_5. The pre-built machines are not exactly the same as mine. The Dell has only a 512 GB SSD (a 1 TB SSD would cost about 79,000 KZT more, and it would still be cheaper than my build by about 64,000 KZT). The HP has Windows, a keyboard, a mouse and a stronger 20-core Intel CPU, and it has 32 GB, so even against a 32 GB version of my sales build (733,340 KZT) it costs about 358,000 KZT more. The PULSER has an RTX 5060 and no Windows in the price: with a Windows licence (123,990 KZT) it costs about 1,007,700 KZT, almost the same as my designer build.

What the company gains by buying pre-built: one warranty for the whole machine, one place to call for support, and no time spent on choosing, assembling and testing parts. What it loses: the choice of parts (for example, the SSD size or the graphics card), the upgrade path (branded machines often use special cases and power supplies), and in most of my comparisons also money. Only the Dell is cheaper, and only because its SSD is smaller.

**Who will complain within a month, and about what?**
The sales manager, about memory. 16 GB with a CRM in 30-40 browser tabs, Excel and a video call at the same time can fill up, and then the machine starts to swap in the middle of a call. This is the price of the choice I made to save money during the memory price peak, and the fix (a second 2x8 GB kit) is cheap and ready.

## 4. Evidence

- [evidence/vendor-quotes/](evidence/vendor-quotes/) - screenshots of every price on Shop.kz with the date and time visible, named role-part (for example sales-memory.png).
- evidence/vendor-quotes/designer-monitor-specs.png - the specification of the designer's monitor (screen section, colour gamut).
- evidence/vendor-quotes/prebuilt-hp-prodesk.png - screenshot of the order page with the price of the HP ProDesk.
- [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md) - one PCPartPicker list per build, used to check compatibility and power (PCPartPicker does not show prices in tenge).
- [evidence/vendors.md](evidence/vendors.md) - the vendor and the product number of every part.

## 5. What I would do differently

I would ask the director the questions from section 2 before choosing any parts, especially about the accounting software and the designer's programs. I would also measure real memory use on a computer of the sales team with the real CRM and video calls, instead of choosing by my own estimate, because that is the decision where I took the biggest risk. And since memory prices change quickly, I would check the memory price in a second store just before ordering.

## AI use

I used an AI assistant to help plan the builds. I checked the numbers and rewrote the answers in my own words.
