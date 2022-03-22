# VSIMCLI
A command line tool for building and managing ONTAP Simulator Virtual Machines

## Description

vsimcli is a shell script for building and managing a local vsim (NetApp ONTAP **V**irtual **SIM**ulator) environment.  Originally built for MacOS with VMware Fusion, it now also works on Linux with VMware Workstation, and (experimentally) on WSL with VMware Workstation. Some of its functionality includes:
 - Importing/Exporting simulator OVA or TGZ archives
 - Creating simulator VMs from an ONTAP image.tgz software package
 - Offline reconfiguration/upgrade of a VMs configuration, loader environment, and installed ONTAP images
 - Start/Stop of local Simulator VMs
 - Connecting to a vsim's serial console

## Installation

To install:
  1. Download the 9.9.1 version of the simulator and license file from the NetApp support site:
     "https://mysupport.netapp.com/api/tools-service/toolsbinary/simulate-ontap/download/vsim-netapp-DOT9.9.1-cm_nodar.ova"

     "https://mysupport.netapp.com/api/tools-service/toolsbinary/simulate-ontap/download/CMode_licenses_9.8.txt"

  2. Place the vsim-netapp-DOT9.9.1-cm_nodar.ova and the CMode_licenses_9.9.1.txt files in the same directory as the install.sh script

  3. Run the install.sh script as sudo:
       sudo ./install.sh

The vsim script and simlinks to some VMware components will be placed in: /usr/local/bin

Completions (tab complete for the vsim command) will be added to: ~/.bashrc and ~./zshrc

Blank vsim templates will be placed in $HOME/vsims, which is also where managed vsims are placed by default.

ONTAP software images will be stored in: $HOME/vsims/ontap

The local NFS server on OSX will be configured to export $HOME/vsims to the VMWare 'host only' subnet.  This is required for local vsim HA to function.

## Usage

Usage:
vsim <command> [options]

Help:
vsim help <command>

Available Commands:

    console                     Connect to a vsim console
    configure                   configure an ONTAP Select VM (experimental)
    create                      Create a vsim
    delete                      Delete a vsim
    deploy                      Deploy a vsim to an ESXi host (experimental)
    export                      Export a vsim
    help                        Display help
    image                       Manage a vsim's software images
    import                      Import a vsim or software package
    modify                      Modify a vsim
    mount                       Mount a vsim's cf card
    options                     Show and Set options and paths
    package                     Manage the package repository
    poweroff                    Poweroff a vsim (poweroff vm)
    printenv                    Print a vsim's loader environment
    printvmx                    Print a vsim's vmx file
    rename                      Rename a vsim
    run                         Run commands in a vsim shell
    setenv                      Set a loader variable
    setvmx                      Set a vmx variable
    show                        Display vsims
    start                       Start a vsim
    stop                        Stop a vsim (shutdown guest)
    suspend                     Suspend a vsim
    unmount                     Unmount a vsim's cf card
    unsetenv                    Unset a loader variable
    unsetvmx                    Unset a vmx variable
    update                      Update a vsim's ontap image



To see the available options for a command:
vsim help <command>

## Examples

Import some Data ONTAP images into the repository:

    vsim package -get ~/Downloads/824_q_image.tgz
    vsim package -get ~/Downloads/97_q_image.tgz

Show the available software images:

    vsim package -show

Create a simple vsim:

    vsim create -vsim vsim1 -version 9.9.1

Create a vsim that automatically creates a new cluster named 'demo':

    vsim create -vsim demo-01 -version 9.9.1 -cluster demo

Start vsim demo-01:

    vsim start demo-01

Connect to the console of demo-01:

    vsim console demo-01

To disconnect from the console, press ctrl-G

Create a second node for cluster demo:

    vsim create -vsim demo-02 -version 9.9.1 -serial 4034389062

Create a simple 7mode vsim:

    vsim create -vsim myvsim1 -version 8.2.4 -mode 7

Create a 7mode vsim that will auto configure itself on first boot:

    vsim create -vsim myvsim1 -version 8.2.4 -mode 7 -auto

Create an 7mode HA pair of vsims (Fusion 10.x and older):

    vsim create -vsim 7mode1 -partner 7mode2 -version 8.2.4 -mode 7 -auto

Show a list of vsims and failover disks:

    vsim show

Clean up the 7mode HA pair:

    vsim stop 7mode1
    vsim stop 7mode2
    vsim delete 7mode1
    vsim delete 7mode2

Delete the shared failover disks from the 7mode1/7mode2 ha pair

    vsim delete ha_7mode1_7mode2

## Working with ONTAP Select VMs:
Note: Support for ONTAP Select VMs is limited and experimental

To import an ONTAP Select standalone evluation OVA:

    vsim import ~/Downloads/9.5_DataONTAPv-esx-standalone-nodar.ova -vsim ONTAPSelect

To modify the ONTAP Select VM to fit within the VMware Fusion environment:

    vsim modify -vsim ONTAPSelect -memsize 6144 -vcpus 2 -nat e0a,e0b,e0c -comconsole

To configure the ONTAP Select VM prior to first boot:

    vsim configure -vsim ONTAPSelect

To start the ONTAP Select VM:

    vsim start -vsim ONTAPSelect

To connect to the console of the ONTAP Select VM:

    vsim console -vsim ONTAPSelect

## Known Issues:
- HA NVRAM mirroring stopped working in VMware Fusion 11.  In later versions of VMware, HA can be re-enabled by using the -vmxnet3 cli switch to configure VMXNET3 type virtual network adapters.  This feature requires ONTAP version 9.5 or later.

- Automatic cluster join is no longer working as of ONTAP 9.2.

- ONTAP9 vsims in an HA configuration panic during shutdown or reboot, but otherwise function normally.  For this reason core dump will be disabled by default on HA VSIMS.

## Notes:
- When using -auto to configure vsims the default password for root or admin is set to : netapp1!
  The default can be changed with the command 'vsim options VSIMPASSWORD <new password>'

- Auto configuration (-cluster, -join) is not implemented for versions of Clustered Data ONTAP prior to 8.3

- When using -create and -join, allow the create node to completely stabilize before starting the subsequent nodes

- When using HA mode, HA has to be activated in ONTAP (options cf.mode ha) and the node has to be rebooted before HA can be enabled.

- The "q_image.tgz" can be used for versions of Data ONTAP starting with 8.1.1.  For earlier versions the "v_image.tgz" should be used.
