# Open Source Tool Setup

This project contains a Dockerfile to create a development container. The idea is to provide a simple way for other people to start using open source ASIC design tools. Developed under Hochschule Karlsruhe, University of Applied Sciences -- Karlsruhe, Germany. Abbreviation HKA.

Author: Jan Hoegen
Prof: Herman Jali Ng

## Requirements

Currently, this project is in development. We are working on a Windows 11 Host machine. 2 different usage methods are supported:
1. Run your development projects on C filesystem and use Cygwin for GUI support to the docker container
2. Run your development on either the C filesystem or a WSl distribution and use WSLg for GUI support to the docker container.

Necessary tools on your Win11 host machine are:

- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/), check its installation guide
- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install), e.g. `wsl --install`

### Option 1: Cygwin

We will install [Cygwin](https://x.cygwin.com/docs/ug/setup.html) with these commands:

```powershell
winget install Cygwin.CygwinSetup
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
mkdir "$HOME\cygwin", "$HOME\cygwin\packages", "$HOME\cygwin\root"
cygwinsetup --root $HOME/cygwin/root --local-package-dir "$HOME/cygwin/packages" --no-admin --no-desktop  --no-shortcuts  --no-startmenu --site  https://cygwin.itefix.net  --packages xhost xlaunch xorg-docs xterm xinit xorg-server
```

click yes/next until the installation is finished. 

#### Activate Xwin

Next, we have to activate the XWin:

```powershell
cd "$HOME\cygwin\root"
.\Cygwin.bat
```

and run this in the new window:

```bash
XWin :0 -listen tcp -multiwindow &
export DISPLAY=:0.0
```

You can stop xwin listening with this in your host powershell terminal:

```powershell
Stop-Process -Name XWin -Force
```

#### Install PDK

Next, install the pdk of your choice:

```powershell
mkdir $HOME/pdks
cd $HOME/pdks

git clone --branch dev --recurse-submodules https://github.com/IHP-GmbH/IHP-Open-PDK.git
cd IHP-Open-PDK

echo "export PDK_ROOT=\$HOME/your_directory/IHP-Open-PDK" >> ~/.bashrc
echo "export PDK=ihp-sg13g2" >> ~/.bashrc
echo "export KLAYOUT_PATH=\"\$HOME/.klayout:\$PDK_ROOT/\$PDK/libs.tech/klayout\"" >> ~/.bashrc
echo "export KLAYOUT_HOME=\$HOME/.klayout" >> ~/.bashrc
source ~/.bashrc

pip install -r requirements.txt
```

### Option 2: WSL

the following tools are required on your wsl path:

- [Python](https://www.python.org/downloads/), e.g. `sudo apt install python3`
- [uv](https://docs.astral.sh/uv/getting-started/installation/#standalone-installer), e.g. `curl -LsSf https://astral.sh/uv/install.sh | sh`
- [ciel 2.4.0](https://github.com/fossi-foundation/ciel): e.g. `uv tool install ciel==2.4.0`

#### Install PDK

Inside your wsl shell, run:

```bash
PDK_ROOT=$HOME/pdks
PDK=ihp-sg13g2
ciel enable --pdk-family $PDK --pdk-root $PDK_ROOT c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c
```

## Clone the Repository

Clone this repository into a user-writable directory, such as a folder under `C:\Users\<username>\projects`:

```powershell
mkdir $HOME/projects # or any other user path
Set-Location $HOME/projects
git clone https://github.com/JanHoegenIHP/tools-setup
Set-Location tools-setup
```

## Development

Build the image from the project directory:

```powershell
make build
```

The following command generates a shell from inside the dev container. The `example` folder from this repository as well as the PDK from the requirement are mounted.

```powershell
make run
```

Export the built image with:

```powershell
make save
```

## Usage

At a later stage, the container will be hosted externally, e.g. by dockerhub, ILIAS, etc. These are the steps for a user to get the dev container, after following the requirements.

Run the container:

```powershell
make run
```

Or load an exported image to the new machine and load it with:

```powershell
docker load --input .\hka-tools-asic.tar
```


### Try Out the Example

After `task run`, you will be dropped into a Bash shell inside the development container.

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

fix klayout ihp pdk drc importerror. most likely solution: fix python environment path

fix klayout 2.5 d viewer errors. most likely solution: add missing ui dependencies

fix permission errors when project is on windows file path

fix "used by another process" for ciel install on windows

use build stages whereever possible

pin softwares to specific versions

add smoke tests

add uv sync to makefile run 

add vhdl to gds test

add xschem, ngspice

generate a list dynmically of all apps the dev container provides

add license

## Sources

- [IHP PDK](https://ihp-open-pdk-docs.readthedocs.io/en/latest/index.html)
- [Pretl Docker Container](https://github.com/iic-jku/iic-osic-tools)
- [XSCHEM SKY130 Install Guide](https://xschem.sourceforge.io/stefan/xschem_man/tutorial_xschem_sky130.html)