# Windows with Docker

Run docker with GUI natively on windows without using WSL.

## Requirements

download from [setup page](https://x.cygwin.com/docs/ug/setup.html)

click on  `setup-x86_64.exe` to download it to your Downloads folder. Then in a Powershell prompt:

```powershell
cd $HOME/Downloads
mkdir $HOME/cygwin-user
mkdir $HOME/cygwin-packages
& .\setup-x86_64.exe -B -R "$HOME\cygwin-user" --no-write-registry --no-startmenu  --local-package-dir "$HOME/cygwin-packages"
```

select yes/next on each step until you get a table view to select packages.

Select:
- xorg-server
- xinit
- xterm
- xorg-docs
- xlaunch

Select yes/next until all packages are installed.

### Confirm installation

```powershell
cd $HOME/cygwin-user
.\Cygwin.bat
```

then in the bash shell:

```bash
cygcheck -c xorg-server xinit xterm xorg-docs
```

## Usage

```powershell
cd $HOME/cygwin-user
.\Cygwin.bat
```

Then in your cygwin bash shell:

```bash
# startxwin
XWin :0 -listen tcp -multiwindow &
export DISPLAY=:0.0
xterm # test if this UI works
```

Now, switch to your windows powershell and test xeyes UI from docker container:

```powershell
docker run --rm -it -e DISPLAY=host.docker.internal:0.0   debian:bookworm-slim  bash -c "apt-get update && apt-get install -y x11-apps && xeyes"
```