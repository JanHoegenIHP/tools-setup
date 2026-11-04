# Open Source Tool Setup

The idea is to provide a simple way for other people to start using open source ASIC design tools. Developed under Hochschule Karlsruhe, University of Applied Sciences -- Karlsruhe, Germany. Abbreviation HKA.

Author: Jan Hoegen
Prof: Herman Jali Ng

## Requirements

Currently, this project is in development. We are working on a Windows 11 Host machine. Necessary tools are:

- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install), install with `wsl --install`
- make, e.g. `winget install ezwinports.make`

## Usage

```bash
make build
```

```bash
make run
```

## VHDL counter example

The example design is a parameterized synchronous counter in `src/counter.vhd`.
Its GHDL testbench checks reset, enable/hold behavior, and rollover:

```bash
mkdir -p build/ghdl
ghdl -a --std=08 --workdir=build/ghdl src/counter.vhd tests/tb_counter.vhd
ghdl -e --std=08 --workdir=build/ghdl tb_counter
ghdl -r --std=08 --workdir=build/ghdl tb_counter --assert-level=error
```

Run the LibreLane flow with `librelane config.yaml` from the project root.
The config selects LibreLane's `VHDLClassic` flow and the IHP SG13G2 PDK; make
sure that PDK is installed in your LibreLane PDK root first.

## To Dos

remove IHP PDk from docker container. mount it from the host machine.

pin softwares to specific versions

todo: [ui on windows](https://github.com/NaPiZip/Docker-GUI-Apps-on-Windows)

- `make run` uses Ubuntu WSL and WSLg to display Linux GUI applications.
- `make run-windows-x11` runs Docker directly from Windows and forwards X11 to a Windows X server. Start VcXsrv first (display `0`, multi-window mode, no client), then use this target. The Makefile defaults to `host.docker.internal:0.0`; override `WINDOWS_X11_DISPLAY` if the server uses another display.

add vhdl to gds test

## Sources

- [IHP PDK](https://ihp-open-pdk-docs.readthedocs.io/en/latest/index.html)
- [Pretl Docker Container](https://github.com/iic-jku/iic-osic-tools)