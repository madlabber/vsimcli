#!/bin/bash
errCount=0
# if [[ $UID != 0 ]]; then
#     echo "Please run this script with sudo:"
#     echo "sudo -E $0 $*"
#     # exit 1
# fi

# decide where to install to
if [ -z "$VSIMHOME" ] && [ -f "$HOME/.vsimrc" ];then VSIMHOME="$(cat ~/.vsimrc | grep ^VSIMHOME|cut -d'"' -f 2)";fi
if [ -z "$VSIMHOME" ]; then VSIMHOME="$HOME/.vsim";fi
export VSIMHOME="$VSIMHOME"
echo "VSIMHOME=$VSIMHOME"

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

if [ -f "standard.tgz" ];then
  echo "+ A standard vSIM template was found: standard.tgz"
else
	echo "- A standard vSIM template was not found."
fi

ovafile="$(ls vsim-netapp-DOT9.*.ova 2> /dev/null| tail -n 1)"
if ! [ -f "$ovafile" ];then
  ovafile="$(ls ~/Downloads/vsim-netapp-DOT9.*.ova 2> /dev/null| tail -n 1)"
fi

if [ -f "$ovafile" ];then
  echo "+ Found: $ovafile"
else
  echo "- A vSIM OVA file was not found."
fi

# At least one of these must be present to continue.
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
echo "Creating $VSIMHOME directories"
mkdir -p "$VSIMHOME"
mkdir -p "$VSIMHOME/ontap"
mkdir -p "$VSIMHOME/cfcard"
mkdir -p "$VSIMHOME/bin"
chmod -R 777 "$VSIMHOME"

# #Scripts go here if they can
# if [ -w /usr/local ]; then
#   echo
#   echo "Copying files to /usr/local/bin:"
#   mkdir -p /usr/local/bin
#   cp vsim /usr/local/bin
#   if [ -f "/usr/local/bin/vsim" ]; then
#   	echo "+ /usr/local/bin/vsim"
#   fi
#   cp .vsim-completion.sh /usr/local/bin
#   if [ -f "/usr/local/bin/.vsim-completion.sh" ]; then
#   	echo "+ /usr/local/bin/.vsim-completion.sh"
#   fi
# fi

# And here
echo
echo "Copying files to $VSIMHOME/bin:"
cp vsim $VSIMHOME/bin
if [ -f "$VSIMHOME/bin/vsim" ]; then
	echo "+ $VSIMHOME/bin/vsim"
fi
cp vsim-completion.sh $VSIMHOME/bin
if [ -f "$VSIMHOME/bin/vsim-completion.sh" ]; then
	echo "+ $VSIMHOME/bin/vsim-completion.sh"
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
echo "Updating .bashrc:"
bashrc="$HOME/.bashrc"
src="source $VSIMHOME/bin/vsim-completion.sh"
bashpath='export PATH="'$VSIMHOME'/bin:$PATH"'
if ! [ -f "$bashrc" ];then touch "$bashrc";fi
if ! grep "$src" "$bashrc";then	echo "$src" >> "$bashrc";fi
if ! grep "$bashpath" "$bashrc";then echo "$bashpath" >> "$bashrc";fi

#configure zshrc for newer macos
echo
echo "Updating .zshrc:"
zshrc="$HOME/.zshrc"
zshpath='export PATH='$VSIMHOME'/bin:$PATH'
if ! [ -f "$zshrc" ];then touch "$zshrc";fi
if ! grep "compinit" "$zshrc";then echo "autoload -U +X compinit && compinit" >> "$zshrc";fi
if ! grep "bashcompinit" "$zshrc";then echo "autoload -U +X bashcompinit && bashcompinit" >> "$zshrc";fi
if ! grep "$src" "$zshrc";then echo "$src" >> "$zshrc";fi
if ! grep "$zshpath" "$zshrc";then echo "$zshpath" >> "$zshrc";fi

#Build templates if necessary
#Build standard.tgz from the ova
if ! [ -f "standard.tgz" ];then
    echo
    echo "Building standard diskmodel template."
    ./vsim delete standard
    ./vsim import -file "$ovafile" -name "standard"
    echo "Exporting standard.tgz"
    ./vsim export standard -tgz
    ./vsim delete standard
fi

# Import ovafile as template
if [ -f "$ovafile" ];then
  echo
  echo "Importing templates."
  echo "+ $ovafile"
  result="$(./vsim import -file "$ovafile" -vsim template -template -image1 )"
  #echo "$result"
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
rm "$VSIMHOME/cfcard/mfg_l_f" 2> /dev/null
touch "$VSIMHOME/cfcard/mfg_l_f"
if [ -f "$license_file" ];then
	sed 's/\t/ /g' "$license_file" | tr -s ' ' | cut -d' ' -f 2 |grep AAAAA>"$VSIMHOME/cfcard/mfg_l_f"
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
echo "Copying files to $VSIMHOME:"

cp standard.tgz $VSIMHOME 2>/dev/null
if [ -f "$VSIMHOME/standard.tgz" ];then
	echo "+ $VSIMHOME/standard.tgz"
	cp standard.tgz $VSIMHOME
fi
cp classic.tgz $VSIMHOME 2>/dev/null
if [ -f "$VSIMHOME/classic.tgz" ];then
	echo "+ $VSIMHOME/classic.tgz"
fi
cp universal.tgz $HOME/vsims 2>/dev/null
if [ -f "$VSIMHOME/universal.tgz" ];then
	echo "+ $VSIMHOME/universal.tgz"
fi

failed=0
if ! [ -f "$VSIMHOME/bin/vsim" ]; then failed=1;fi
if ! [ -f "$VSIMHOME/standard.tgz" ];then failed=1;fi

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
