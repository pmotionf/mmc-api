# PMF MMC system
PMF provides the Motion Motor Control (MMC) system for controlling Linear Motor Systems (LMS) with ease and high precision.

## Getting started
### MMC Server
The MMC Server acts as an endpoint for multiple clients to interface with the LMS. The server must run on a PC connected to the first driver of the LMS. Contact our engineers to obtain the MMC Server files and organize them as follows:
``` { .md .no-copy}
mmc-server
├─ config.json5
├─ mmc.exe
└─ mmc.pdb
```
Navigate to the `mmc-server` folder and run the executable:
```
mmc.exe --log_level=info
```
### MMC-API
Our API is built with [Protobuf](https://protobuf.dev/), offering 
cross-language compatibility to support your programming language of choice. To 
integrate our API into your program, ensure your working environment supports 
Protobuf. For complete integration instructions, see the [MMC-API Guidelines](.
/mmc-api.md) page.

## Conventions
This section defines the terminology used throughout the PMF MMC documentation.

### System Hierarchy
The following terms apply to the PMF MMC system:

- `Sensor`: A hall sensor installed next to a motor to determine the accurate location of a carrier on a line.
- `Axis`: A functional unit consisting of one motor and the two adjacent hall sensors.
- `Driver`: A physical board responsible for controlling one or more axes. The number of axes per driver is defined in the `config.json5` file. A single driver can control up to **3 axes**.
- `Line`: A unit consisting of one or more drivers. Driver, axis, and carrier states are determined on a per-line basis.
- `Track`: The highest-level unit in the PMF MMC system, consisting of one or more lines. One MMC Server operates exactly one track.
- `Carrier`: Magnet to be moved by PMF's MMC system that is placed on top of LMS. Every carrier must have unique ID per line.
### ID Constraints

!!! info "Important: ID Indexing"
    All system IDs (Lines, Drivers, Axes, and Carriers) use **1-based indexing**. The first ID is always `1`.

| Entity | Max ID | Calculation / Notes |
| :--- | :---: | :--- |
| **Line** | 256 | Maximum lines supported per track. |
| **Driver** | 256 | Maximum drivers per line. |
| **Axis** | 768 | Based on 256 drivers × 3 axes per driver. |
| **Carrier** | 768 | Maximum number of moveable magnet per line. |
