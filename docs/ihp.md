# IHP OPenPDK Install Documentation

This is copied from the offical [IHP install guide](https://ihp-open-pdk-docs.readthedocs.io/en/latest/install/dependencies.html#build-tools).

It serves as a reference document, the steps described here are **not** implemented in the docker dev image!

## Dependcies

```bash
sudo apt-get install -y build-essential
sudo apt-get install -y qtbase5-dev qttools5-dev
sudo apt-get install -y clang cmake libtool autoconf
sudo apt-get install -y python3 python3-dev python3-pip python3-virtualenv python3-venv
sudo apt-get install -y ruby ruby-dev

sudo apt-get install -y btop tree xterm graphviz git
sudo apt-get install -y octave liboctave-dev

sudo apt-get install -y python3-sphinx python3-sphinx-autoapi python3-pandas python3-tk python3-pytest
sudo apt-get install -y libqt5xmlpatterns5-dev qtmultimedia5-dev libqt5multimediawidgets5 libqt5svg5-dev libqt5opengl5
sudo apt-get install -y tcl8.6 tcl-dev tcl8.6-dev
sudo apt-get install -y tk8.6 tk8.6-dev
sudo apt-get install -y flex clang gawk xdot pkg-config bison curl help2man perl time
sudo apt-get install -y libxpm4 libxpm-dev libgtk-3-dev libffi-dev
sudo apt-get install -y libjpeg-dev libfl-dev libfl2
sudo apt-get install -y libreadline-dev gettext
sudo apt-get install -y libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev
sudo apt-get install -y libx11-6 libx11-dev
sudo apt-get install -y libxrender1 libxrender-dev
sudo apt-get install -y libxcb1 libx11-xcb-dev
sudo apt-get install -y libcairo2 libcairo2-dev libxaw7-dev
sudo apt-get install -y libgz libfl2 libfl-dev zlibc zlib1g zlib1g-dev libz-dev libgit2-dev
sudo apt-get install -y libgoogle-perftools-dev
sudo apt-get install -y gengetopt groff pod2pdf libhpdf-dev
sudo apt-get install -y libfftw3-dev
sudo apt-get install -y libxml-libxml-perl libgd-perl
sudo apt-get install -y libsuitesparse-dev gfortran swig libspdlog-dev libeigen3-dev liblemon-dev

On Ubuntu 24.04 build gperf from this page: https://www.gnu.org/software/gperf

# sudo pip install PDKMaster # sudo pip install h5py
```

## Installation

Since is developed on Ubuntu Linux LTS version it is recommended to use it. To get the PDK one will need a git client. Also in order to compile the Verilog-A models for ngspice simulator openvaf tool will be necessary. In a case the user would like to use Xyce simulator the Verilog-A models have to be compiled using ADMS tool. The list of supported tools is listed here and the tools should be installed by the user following the installation guides provided by the developers. It is recommended to use most up to date tool’s versions.

Unlikely the existing manufacturable PDK’s, namely SKY130 and GF180, our IHP-Open-PDK does not require installation. It delivers ready to use primitives and tool configuration files in order to minimize the configuration effort. In order to get the PDK you should clone it from GitHub using the following command:

```bash
git clone --branch dev --recurse-submodules https://github.com/IHP-GmbH/IHP-Open-PDK.git
cd IHP-Open-PDK

echo "export PDK_ROOT=\$HOME/your_directory/IHP-Open-PDK" >> ~/.bashrc
echo "export PDK=ihp-sg13g2" >> ~/.bashrc
echo "export KLAYOUT_PATH=\"\$HOME/.klayout:\$PDK_ROOT/\$PDK/libs.tech/klayout\"" >> ~/.bashrc
echo "export KLAYOUT_HOME=\$HOME/.klayout" >> ~/.bashrc
source ~/.bashrc

pip install -r requirements.txt
```

requirement.txt:
```txt
flake8
docopt
pandas
klayout==0.30.5
pyyaml
gdstk
tqdm
termcolor
```

Since Verilog-A models have to be distributed as a source code due to licensing issues, we provide simulator specific compilation scripts that have to be run once after cloning the PDK. The scripts are located in the $PDK_ROOT/$PDK/libs.tech/verilog-a folder and compile the Verilog-A models either to OSDI binary utilizaed by ngspice and VACASK or .so shared object used by Xyce. To perform the compilation user should run the following commands:

```bash
source openvaf-compile-va.sh
source adms-compile-va.sh
```

### Xschem

XSCHEM is an open source schematic capture tool hosted here. It is capable to stream a customizable netlist, interoperates with simulators and post process the simulation results. To be used with IHP-Open-PDK it is strongly recommended to install xschem from sources using the latest release hosted on github.

After successful installation you can call the following command in the PDK_ROOT/ihp-sg13g2/libs.tech/xschem/ directory:

```bash
python3 install.py
```

It will compile and install a psp103_nqs.osdi binary and place it in $PDK_ROOT/$PDK/ngspice/openvaf/ directory. The file is mandatory for a simulation of our mosfet devices. The script will also creates a symbolic link to the $PDK_ROOT/$PDK/ngspice/.spiceinit file in your home directory. This approach permits to simulate circuits containing elements form IHP-Open-PDK in any directory. After this step you can call xschem & command to run the tool, what will bring the top level hierarchy schematic with a couple of examples segmented by simulation type.

### ngspice

Ngspice is an open source simulator hosted at this page. The tool is well documented and the user manual can be found here. In order to install ngspice the recommended method is the following:

```bash
git clone https://git.code.sf.net/p/ngspice/ngspice ngspice-ngspice
cd ngspice-ngspice
./autogen.sh
./configure --enable-osdi
make
sudo make install
cd ..
rm -rf ngspice-ngspice
```

### pygmid

pygmid is a Python 3 version of the gm/ID starter kit by Prof. Boris Murmann of Stanford University. The package also offers some scripts from the Paul Jesper’s and Boris Murmann’s book entitled: “Systematic Design of Analog CMOS Circuits: Using Pre-Computed Lookup Tables” To be used with IHP-Open-PDK it latest release hosted on github.

After successful cloning of the repository you can execute:

```bash
cd pygmid
python3 install .
```

The device characterization is done once per technology according to the configuration. The example configuration file is stored under the following location tests/pygmid/sweep/IHP130nm.cfg in the ngspice branch. In order to characterize the mosfet devices run the following command:

```bash
python3 -m pygmid --mode sweep --config ~./tests/pygmid/sweep/IHP130nm.cfg
```

Since the pygmid tool calls ngspice in the cwd the psp103_nqs.osdi file has to be present in the same directory.