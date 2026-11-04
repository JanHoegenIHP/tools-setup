# Open Source Tools Setup

## Requirements

Provide Open Source ASIC Design Workflow, Tools, PDK, for chip developers.

- **Target Audience:** University Students, maybe interested professors/teachers
- **Platforms:** Linux, Windows, MacOS
- **Technology:** IHP PDK 130nm. Others could be added later.
- **Deployment:** on local user machine. *Must be offline installabe.* Server based install will be investigated later 
- **Setup:** Size must not grow with simulation data, use user space for that. Size of Installation/Setup should be minimal. 
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

### Dev Container

uses the docker container and additionally provides IDE workspace. E.g. VS Code with necessary extensions. Single Click to action.

### bash scipt

install script that will be run either on the users local linux os or inside their WSL, if on Windows.

Needs switch cases for different OS.

### Configured VirtualBox

fully configured os. but uses more resources, sharing folders with host OS is difficult.

### WSL tar export

wsl snapshot can be exported for reproducible dev setup. can not be used on linux or macos.
