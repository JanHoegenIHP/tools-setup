# Windows USe

## Install GUI

download from [setup page](https://x.cygwin.com/docs/ug/setup.html)

click on  `setup-x86_64.exe`

```powershell
cd Downloads
mkdir $HOME/cygwin-user
mkdir $HOME/cygwin-packages
& .\setup-x86_64.exe -B -R "$HOME\cygwin-user" --no-write-registry --no-startmenu  --local-package-dir "$HOME/cygwin-packages"
```

Select:
- xorg-server
- xinit
- xterm
- xorg-docs
- xlaunch

### Confirm

```powershell
cd $HOME/cygwin-user
.\Cygwin.bat
```

Then in your cygwin bash shell:

```bash
cygcheck -c xorg-server xinit xterm xorg-docs
startxwin
```