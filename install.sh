#!/bin/bash
errCount=0
# if [[ $UID != 0 ]]; then
#     echo "Please run this script with sudo:"
#     echo "sudo -E $0 $*"
#     # exit 1
# fi

echo
echo "Checking dependencies."

#Make sure fusion is installed:
OVFTOOL="/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/ovftool"
VDISKMANAGER="/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
VMRUN="/Applications/VMware Fusion.app/Contents/Library/vmrun"

#If those failed, maybe it is a tech preview of Fusion:
if ! [ -f "$OVFTOOL" ];then OVFTOOL="/Applications/VMware Fusion Tech Preview.app/Contents/Library/VMware OVF Tool/ovftool";fi
if ! [ -f "$VDISKMANAGER" ];then VDISKMANAGER="/Applications/VMware Fusion Tech Preview.app/Contents/Library/vmware-vdiskmanager";fi
if ! [ -f "$VMRUN" ];then VMRUN="/Applications/VMware Fusion Tech Preview.app/Contents/Library/vmrun";fi

#Or this might be WSL
if ! [ -f "$OVFTOOL" ];then OVFTOOL="/mnt/c/Program Files (x86)/VMware/VMware Workstation/OVFTool/ovftool.exe";fi
if ! [ -f "$VDISKMANAGER" ];then VDISKMANAGER="/mnt/c/Program Files (x86)/VMware/VMware Workstation/vmware-vdiskmanager.exe";fi
if ! [ -f "$VMRUN" ];then VMRUN="/mnt/c/Program Files (x86)/VMware/VMware Workstation/vmrun.exe";fi

#OVFTOOL Might be installed as a standalone package
if ! [ -f "$OVFTOOL" ];then OVFTOOL="/Applications/VMware OVF Tool/ovftool";fi

#Or this might be linux:
if ! [ -f "$OVFTOOL" ];then OVFTOOL="/usr/lib/vmware-ovftool/ovftool";fi

#If they aren't in default locations check the path
if ! [ -f "$OVFTOOL" ];then OVFTOOL=$(which ovftool);fi
if ! [ -f "$VDISKMANAGER" ];then VDISKMANAGER=$(which vmware-vdiskmanager);fi
if ! [ -f "$VMRUN" ];then VMRUN=$(which vmrun);fi

if ! [ -f "$OVFTOOL" ] || ! [ -f "$VDISKMANAGER" ] || ! [ -f "$VMRUN" ];then
	echo "VMware components....FAILED"
	echo
	echo "One or more VMware components were not found:"
	if ! [ -f "$OVFTOOL" ];then echo "missing: OVFTOOL";((errCount++));fi
	if ! [ -f "$VDISKMANAGER" ];then echo "missing: VDISKMANAGER";((errCount++));fi
	if ! [ -f "$VMRUN" ];then echo "missing: VMRUN";fi
	echo "Install VMware Fusion/Workstation and try the installation again."
fi

if ! [ -f "classic.tgz" ];then
		echo "- A classic vSIM template was not found."
		#echo "This will prevent the creation of vsims running 8.0.x releases of Data ONTAP."
		#echo "Plase download the workstation version and place it in this"
		#echo "folder, then try the installation again."
		#echo "This file can be downloaded from mysupport.netapp.com at:"
		#echo "http://mysupport.netapp.com/NOW/cgi-bin/simulatorlic8.cgi/download/tools/simulator/ontap/8.1/vsim-DOT81-cm-esx.zip"
		#((errCount++)) -- non-fatal
fi

if ! [ -f "standard.tgz" ];then
	echo "- A standard vSIM template was not found."
	ovafile="vsim-netapp-DOT9.9.1-cm_nodar.ova"
fi

# lazy search for a supported ova
if ! [ -f "$ovafile" ];then
  ovafile="vsim-netapp-DOT9.9.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="vsim-netapp-DOT9.10.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="vsim-netapp-DOT9.11.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="vsim-netapp-DOT9.12.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="vsim-netapp-DOT9.13.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="vsim-netapp-DOT9.14.1-cm_nodar.ova"
fi
# also look in downloads
if ! [ -f "$ovafile" ];then
  ovafile="~/Downloads/vsim-netapp-DOT9.9.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="~/Downloads/vsim-netapp-DOT9.10.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="~/Downloads/vsim-netapp-DOT9.11.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="~/Downloads/vsim-netapp-DOT9.12.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="~/Downloads/vsim-netapp-DOT9.13.1-cm_nodar.ova"
fi
if ! [ -f "$ovafile" ];then
  ovafile="~/Downloads/vsim-netapp-DOT9.14.1-cm_nodar.ova"
fi

if [ -f "$ovafile" ];then 
  echo "+ A vSIM OVA file was found: $ovafile"
fi
if [ -f "standard.tgz" ];then
  echo "+ A standard vSIM template was found: standard.tgz"
  echo "..using existing standard.tgz"
fi


if ! [ -f "$ovafile" ] && ! [ -f "standard.tgz" ];then
        echo ""
		echo "  An existing vsim OVA file is required."
		echo "  Plase download vsim-netapp-DOT9.9.1-cm_nodar.ova or newer and "
		echo "  place it in this folder, then try the installation again."
		echo "  This file can be downloaded from the mysupport.netapp.com at:"
		echo "  https://mysupport.netapp.com/api/tools-service/toolsbinary/simulate-ontap/download/vsim-netapp-DOT9.9.1-cm_nodar.ova"
		((errCount++))
fi

#If something went wrong bail out now
if [ $errCount -ne 0 ];then
	echo
	echo "!!Dependency check failed!!"
	echo "!!Installation cancelled!!"
	exit 1
fi

echo
echo "Proceeding with installation."

# make directory structure
echo
echo "Creating $HOME/vsims directories"
mkdir -p "$HOME/vsims"
mkdir -p "$HOME/vsims/ontap"
mkdir -p "$HOME/vsims/cfcard"
mkdir -p "$HOME/vsims/bin"
chmod -R 777 "$HOME/vsims"

#Scripts go here if they can
if [ -w /usr/local ]; then
  echo
  echo "Copying files to /usr/local/bin:"
  mkdir -p /usr/local/bin
  cp vsim /usr/local/bin
  if [ -f "/usr/local/bin/vsim" ]; then
  	echo "+ /usr/local/bin/vsim"
  fi
  cp .vsim-completion.sh /usr/local/bin
  if [ -f "/usr/local/bin/.vsim-completion.sh" ]; then
  	echo "+ /usr/local/bin/.vsim-completion.sh"
  fi
fi

# And here
echo
echo "Copying files to $HOME/vsims/bin:"
mkdir -p $HOME/vsims/bin
cp vsim $HOME/vsims/bin
if [ -f "$HOME/vsims/bin/vsim" ]; then
	echo "+ $HOME/vsims/bin/vsim"
fi
cp .vsim-completion.sh $HOME/vsims/bin
if [ -f "$HOME/vsims/bin/.vsim-completion.sh" ]; then
	echo "+ $HOME/vsims/bin/.vsim-completion.sh"
fi




#Simlinks go here too
# These are for administrator convenience and not used by the tool
if [ -w /usr/local ]; then
  echo "Creating symlinks for VMware Fusion components"
  ln -s "$VMRUN" "/usr/local/bin/vmrun" 2>/dev/null
  if [ -f "/usr/local/bin/vmrun" ]; then
  	echo "+ /usr/local/bin/vmrun"
  fi
  ln -s "$OVFTOOL" "/usr/local/bin/ovftool" 2>/dev/null
  if [ -f "/usr/local/bin/ovftool" ];then
  	echo "+ /usr/local/bin/ovftool"
  fi
  ln -s "$VDISKMANAGER" "/usr/local/bin/vmware-vdiskmanager" 2>/dev/null
  if [ -f "/usr/local/bin/vmware-vdiskmanager" ]; then
  	echo "+ /usr/local/bin/vmware-vdiskmanager"
  fi
fi

# configure bashrc for linux
echo
echo "Updating .bashrc"
bashrc="$HOME/.bashrc"
src="source $HOME/vsims/bin/.vsim-completion.sh"
bashpath='export PATH="$HOME/vsims/bin:$PATH"'
if ! [ -f "$bashrc" ];then touch "$bashrc";fi
if ! cat "$bashrc" | grep "$src";then	echo "$src" >> "$bashrc";fi
if ! cat "$bashrc" | grep "$bashpath";then echo "$bashpath" >> "$bashrc";fi

#configure zshrc for newer macos
echo
echo "Updating .zshrc"
zshrc="$HOME/.zshrc"
zshpath='export PATH=$HOME/vsims/bin:$PATH'
if ! [ -f "$zshrc" ];then touch "$zshrc";fi
if ! cat "$zshrc" | grep "compinit";then echo "autoload -U +X compinit && compinit" >> "$zshrc";fi
if ! cat "$zshrc" | grep "bashcompinit";then echo "autoload -U +X bashcompinit && bashcompinit" >> "$zshrc";fi
if ! cat "$zshrc" | grep "$src";then echo "$src" >> "$zshrc";fi
if ! cat "$zshrc" | grep "$zshpath";then echo "$zshpath" >> "$zshrc";fi

#Build templates if necessary
#Build standard.tgz from the ova
if ! [ -f "standard.tgz" ];then
    echo
    echo "Building standard diskmodel template."
    ./vsim delete standard
    ./vsim import -file "$ovafile" -name "standard"
    ./vsim export -vsim standard -image image1

	imagetgz=$(ls *_image.tgz)
    ./vsim import $imagetgz
    ./vsim clean standard
    echo "Exporting tgz"
    ./vsim export standard -tgz
    ./vsim delete standard
fi

echo
echo "Searching for license file."
license_file="$(ls CMode_licenses_*.txt 2> /dev/null| head -n 1)"
if ! [ -f "$license_file" ];then license_file="$(ls ~/Downloads/CMode_licenses_*.txt 2> /dev/null| head -n 1)";fi

if [ -f "$license_file" ];then
  echo "+ Found: $license_file"
else
  echo "- no license files found."
fi
rm "$HOME/vsims/cfcard/mfg_l_f" 2> /dev/null
touch "$HOME/vsims/cfcard/mfg_l_f"
if [ -f "$license_file" ];then
	sed 's/\t/ /g' "$license_file" | tr -s ' ' | cut -d' ' -f 2 |grep AAAAA>"$HOME/vsims/cfcard/mfg_l_f"
  base=$(cat "$license_file" | grep '=' | grep AAAA | cut -d'=' -f 2 | cut -d' ' -f 2)
  ./vsim options VSIMLICENSE "$base"
  vsimserial=$(cat "$license_file" | grep '^Licenses' | cut -d' ' -f 8 | cut -d')' -f 1 | head -1)
  ./vsim options VSIMSERIAL "$vsimserial"
  vsimpartnerserial=$(cat "$license_file" | grep '^Licenses' | grep second | cut -d' ' -f 11 | cut -d')' -f 1)
  ./vsim options VSIMPARTNERSERIAL "$vsimpartnerserial"
fi



# Build Classic.tgz
# At some point
# See prototype in make.sh

#templates go here
echo
echo "Copying files to $HOME/vsims:"
cp standard.tgz $HOME/vsims 2>/dev/null
if [ -f "$HOME/vsims/standard.tgz" ];then
	echo "+ $HOME/vsims/standard.tgz"
	cp standard.tgz $HOME/vsims
fi
cp classic.tgz $HOME/vsims 2>/dev/null
if [ -f "$HOME/vsims/classic.tgz" ];then
	echo "+ $HOME/vsims/classic.tgz"
fi
cp universal.tgz $HOME/vsims 2>/dev/null
if [ -f "$HOME/vsims/universal.tgz" ];then
	echo "+ $HOME/vsims/universal.tgz"
fi

failed=0
if ! [ -f "$HOME/vsims/bin/vsim" ]; then failed=1;fi
if ! [ -f "$HOME/vsims/standard.tgz" ];then failed=1;fi

if [ $failed -ne 0 ];then
	echo "File copy failed.  try again with sudo."
	exit
fi

# Patch up ownership
case "$(uname)" in
	Darwin )
		userid=$(stat -f %u "$HOME")
		groupid=$(stat -f %g "$HOME")
		;;
	Linux  )
		userid=$(stat --format %u "$HOME")
		groupid=$(stat --format %g "$HOME");;
esac
chown -R $userid:$groupid "$HOME/vsims"
chmod -R 777 "$HOME/vsims"


#Now configure NFS based on the vmnet1 settings in VMware
echo
echo "exporting $HOME/vsims may prompt for credentials."
echo "This is only required to support local HA vsims"
echo
vsimhome="$HOME/vsims"
sudo ./vsim options FODDIR "$vsimhome"

#orient the user
echo ""
echo "*************************************"
echo ""
echo "vsim installed."
echo "run vsim from the terminal for usage"
echo ""
echo "vsims will be placed in $vsimhome"
echo ""
echo "Open a new terminal to proceed"
echo ""
echo "*************************************"
echo ""

#exit
