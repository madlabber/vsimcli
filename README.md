# vsim4osx
A vsim toolkit for building and managing ONTAP vsims on (Intel) MacOS and VMware Fusion

## Installation

To install vsim4osx, run the install.sh script as sudo:
sudo ./install.sh

The vsim script and simlinks to some VMware components will be placed in:
/usr/local/bin

On recent versions of OSX this should already be in the path.

Blank vsim templates will be placed in $HOME/vsims, which is also where managed vsims are placed by default.

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
  image                       Manage software images
  import                      Import a vsim or software package
  modify                      Modify a vsim
  mount                       Mount a vsim's cf card
  options                     Show and Set options and paths
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
  cd ~/Downloads
  vsim import 824_q_image.tgz
  vsim import 832_q_image.tgz

Show the available software images:
  vsim image -list

Make a simple 7mode vsim
  vsim create -vsim myvsim1 -version 8.2.4 -mode 7

Make a 7mode vsim that will auto configure itself on first boot
  vsim create -vsim myvsim1 -version 8.2.4 -mode 7 -auto

Change the serial number to match an available license key set:
  vsim modify myvsim1 -serial 4082367544

Start the vsim:
  vsim start myvsim1

Connect to a vsim's console:
  vsim console myvsim1

To exit the console, press ctrl-G

Make an HA pair of vsims:
  vsim create -vsim 7mode1 -partner 7mode2 -version 8.2.4 -mode 7 -auto

Make a Cmode vsim that automatically creates a new cluster
  vsim create -vsim cluster1-01 -version 8.3.2 -cluster cluster1 

Make a Cmode vsim that automatically joins an existing cluster
  vsim create -vsim cluster1-02 -version 8.3.2 -join cluster1 

Make a cDOT HA pair:
  vsim create -vsim cluster2-01 -partner cluster2-02 -version 8.3.2 -cluster cluster2

Show a list of vsims and failover disks
  vsim show

Clean up the 7mode HA pair
  vsim stop 7mode1
  vsim stop 7mode2
  vsim delete 7mode1
  vsim delete 7mode2

Delete the shared failover disks from the 7mode1/7mode2 ha pair
  vsim delete ha_7mode1_7mode2

## Working with ONTAP Select VMs:

To import an ONTAP Select standalone evluation OVA:
  vsim import ~/Downloads/9.5_DataONTAPv-esx-standalone-nodar.ova -vsim ONTAPSelect

To modify the ONTAP Select VM to fit within the VMware Fusion environment
  vsim modify -vsim ONTAPSelect -memsize 6144 -vcpus 2 -nat e0a,e0b,e0c -comconsole

To configure the ONTAP Select VM prior to first boot:
  vsim configure -vsim ONTAPSelect 

To start the ONTAP Select VM:
  vsim start -vsim ONTAPSelect

To connect to the console of the ONTAP Select VM:
  vsim console -vsim ONTAPSelect

## Notes:
- When using -auto to configure vsims the default password for root or admin is set to : netapp1!
  The default can be changed with the command 'vsim options VSIMPASSWORD <new password>'

- Auto configuration (-cluster, -join) is not implemented for versions of Clustered Data ONTAP prior to 8.3

- Automatic cluster join is not longer working as of ONTAP 9.2.

- ONTAP9 vsims in an HA configuration panic during shutdown or reboot, but otherwise function normally.

- When using -create and -join, allow the create node to completely stabilize before starting the subsequent nodes

- When using HA mode, HA has to be activated in ONTAP (options cf.mode ha) and the node has to be rebooted before HA can be enabled.

- The "q_image.tgz" can be used for versions of Data ONTAP starting with 8.1.1.  For earlier versions the "v_image.tgz" should be used.









