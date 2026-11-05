# Open Source Tool Setup

This project contains a `Doockerfile` to create a development container. The idea is to provide a simple way for other people to start using open source ASIC design tools. Developed under Hochschule Karlsruhe, University of Applied Sciences -- Karlsruhe, Germany. Abbreviation HKA.

Author: Jan Hoegen
Prof: Herman Jali Ng

## Requirements

Currently, this project is in development. We are working on a Windows 11 Host machine. Necessary tools are:

- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/), check its installation guide
- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install), e.g. `wsl --install`
- [make](https://www.gnu.org/software/make/), e.g. `winget install ezwinports.make`
- [Python](https://www.python.org/downloads/), e.g. `winget install Python.PythonInstallManager`
- [uv](https://docs.astral.sh/uv/getting-started/installation/#standalone-installer), e.g. `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
- [ciel 2.4.0](https://github.com/fossi-foundation/ciel): e.g. `uv tool install ciel==2.4.0 --force`

### Download PDK

The PDK will live on your host machine. Use

```bash
ciel enable --pdk-family ihp-sg13g2 --pdk-root "$HOME/pdks" c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c
```

## Usage

Create the docker container with

```bash
make build
```

Run a shell from the docker container. This will mount the `example` folder to your container.

```bash
make run
```

### Try Out the Example

after the `make run` in your console, you will be dropped to a bash shell from inside the dev container. 

it already contains a 4 bit counter in vhdl in `src/counter.vhd`. You can inspect its testbench in `tests/test_counter.py` written in [cocotb](https://docs.cocotb.org/en/stable/). To run the testbench simulation and view the waveform results, run:

```bash
make simulate
```

When you confirmed the behvior of the design, you can run the librelane syntheszis workflow. It will generate a full gds result.

```bash
make harden
```

Finally, inspect your generated layout with:

```bash
make rtl-layout
```

## To Dos

fix klayout ihp pdk drc, 2.5 d viewer errors.

add native windows support without wsl with [ui on windows](https://github.com/NaPiZip/Docker-GUI-Apps-on-Windows)

fix permission errors when project is on windows file path

fix "used by another process" for ciel install on windows

use build stages whereever possible

pin softwares to specific versions

add vhdl to gds test

add xschem, ngspice

## Sources

- [IHP PDK](https://ihp-open-pdk-docs.readthedocs.io/en/latest/index.html)
- [Pretl Docker Container](https://github.com/iic-jku/iic-osic-tools)
- [XSCHEM SKY130 Install Guide](https://xschem.sourceforge.io/stefan/xschem_man/tutorial_xschem_sky130.html)