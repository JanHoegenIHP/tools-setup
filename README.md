# Open Source Tools Setup

The idea is to provide a simple way for other people to start using open source ASIC design tools. Developed under Hochschule Karlsruhe, University of Applied Sciences -- Karlsruhe, Germany. Abbreviation HKA.

Author: Jan Hoegen
Prof: Herman Jali Ng

## Requirements

Provide Open Source ASIC Design Workflow, Tools, PDK, for chip developers.

- **Target Audience:** University Students, maybe interested professors/teachers
- **Platforms:** Linux, Windows, MacOS
- **Technology:** IHP PDK 130nm. Others could be added later.
- **Deployment:** on local user machine. *Must be offline installabe.* Server based install will be investigated later 
- **Setup:** 
- **Necssary Tools:**
  - Development
    - make
    - git
    - uv
    - Python
  - Digital Design
    - Librelane
    - ghdl
    - gtkwave
    - Klayout
    - OpenRoad
  - Analog Design (not important right now)
    - ngspice
    - XSchem
    - Qucs (less important than xschem)

## Ideas, Solution

### Docker Container

tools will work on all platforms. supports export and offline install.

use multi stage build!

user workspace must be accesible by host machine, by e.g. mirroring/bin-mounting. internal docker container should not be the dev setup.

todo: dont mirror the .venv to the docker!

#### Windows GUI options

todo: [ui on windows](https://github.com/NaPiZip/Docker-GUI-Apps-on-Windows)

- `make run` uses Ubuntu WSL and WSLg to display Linux GUI applications.
- `make run-windows-x11` runs Docker directly from Windows and forwards X11 to a Windows X server. Start VcXsrv first (display `0`, multi-window mode, no client), then use this target. The Makefile defaults to `host.docker.internal:0.0`; override `WINDOWS_X11_DISPLAY` if the server uses another display.

The direct Windows option requires the X server to accept connections from Docker Desktop. Disabling X-server access control permits unauthenticated access to the display; use it only on a trusted private network, restrict the Windows Firewall rule to private networks, and stop the X server when finished. WSLg remains the safer/simpler default when available.

### Dev Container

uses the docker container and additionally provides IDE workspace. E.g. VS Code with necessary extensions. Single Click to action.

### bash scipt

install script that will be run either on the users local linux os or inside their WSL, if on Windows.

### Configured VirtualBox

fully configured os. but uses more resources, sharing folders with host OS is difficult.

### WSL tar export

wsl snapshot can be exported for reproducible dev setup. can not be used on linux or macos.

## Tasks

1. Learn docker container creation
2. Setup digital tools first. Herman already knows ngspice, xschem installation process.
3. Smoke tests for programs, liek `librelane --smoke-test`
4. test for vhdl to gds

## Sources

- [IHP PDK](https://ihp-open-pdk-docs.readthedocs.io/en/latest/index.html)
- [Pretl Docker Container](https://github.com/iic-jku/iic-osic-tools)