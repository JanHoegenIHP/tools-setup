# Open Source Tool Setup

The idea is to provide a simple way for other people to start using open source ASIC design tools. Developed under Hochschule Karlsruhe, University of Applied Sciences -- Karlsruhe, Germany. Abbreviation HKA.

Author: Jan Hoegen
Prof: Herman Jali Ng

## Requirements

Currently, this project is in development. We are working on a Windows 11 Host machine. Necessary tools are:

- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install), install with `wsl --install`
- make, e.g. `winget install ezwinports.make`
- bash on Windows
- Python: `winget install Python.PythonInstallManager`
- ciel: `python -m pip install --user ciel`, then `$env:Path += ';$HOME\AppData\Roaming\Python\Python314\Scripts'`

or `sudo apt install pipx` then `pipx ensurepath` then `pipx install ciel --force 'ciel==2.4.0'`

### Download PDK

The PDK will live on your host machine. Use

```bash
ciel enable --pdk-family ihp-sg13g2 --pdk-root "$HOME/pdks" c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c
```

Run this in WSL so CIEL caches the selected version under
`$HOME/pdks/ciel/ihp-sg13/versions/.../ihp-sg13g2` (CIEL's canonical family
name is `ihp-sg13`). `make run` bind-mounts the whole host `PDK_ROOT` (default
`$HOME/pdks`) at `/pdks` and aliases that CIEL cache at the family path expected
by the container. If the PDK is stored elsewhere, set `PDK_ROOT` to that parent
directory when invoking `make run`.

## Usage

Create the docker container with

```bash
make build
```

Run a shell from the docker container with the current project mounted to it:

```bash
make run
```

## To Dos

fix permission errors when project is on windows file path

remove IHP PDk from docker container. mount it from the host machine.

use build stages whereever possible

pin softwares to specific versions

todo: [ui on windows](https://github.com/NaPiZip/Docker-GUI-Apps-on-Windows)

- `make run` uses Ubuntu WSL and WSLg to display Linux GUI applications.
- `make run-windows-x11` runs Docker directly from Windows and forwards X11 to a Windows X server. Start VcXsrv first (display `0`, multi-window mode, no client), then use this target. The Makefile defaults to `host.docker.internal:0.0`; override `WINDOWS_X11_DISPLAY` if the server uses another display.

add vhdl to gds test

user workspace must be accesible by host machine, by e.g. mirroring/bin-mounting. internal docker container should not be the dev setup.
todo: dont mirror the .venv to the docker!

## Sources

- [IHP PDK](https://ihp-open-pdk-docs.readthedocs.io/en/latest/index.html)
- [Pretl Docker Container](https://github.com/iic-jku/iic-osic-tools)