#!/bin/bash
errCount=0
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo -E $0 $*"
    exit 1
fi

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
		echo "A classic vSIM template was not found."
		#echo "This will prevent the creation of vsims running 8.0.x releases of Data ONTAP."
		#echo "Plase download the workstation version and place it in this"
		#echo "folder, then try the installation again."
		#echo "This file can be downloaded from mysupport.netapp.com at:"
		#echo "http://mysupport.netapp.com/NOW/cgi-bin/simulatorlic8.cgi/download/tools/simulator/ontap/8.1/vsim-DOT81-cm-esx.zip"
		#((errCount++)) -- non-fatal
fi

if ! [ -f "standard.tgz" ];then
	echo "A standard vSIM template was not found."
	ovafile="vsim-netapp-DOT9.9.1-cm_nodar.ova"
fi

if ! [ -f "$ovafile" ];then
  ovafile="~/Downloads/vsim-netapp-DOT9.9.1-cm_nodar.ova"
fi

if ! [ -f "$ovafile" ] && ! [ -f "standard.tgz" ];then
        echo ""
		echo "  An existing 9.9.1 vsim OVA file is required."
		echo "  Plase download vsim-netapp-DOT9.9.1-cm_nodar.ova and "
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

echo "Proceeding with installation."

#Scripts go here
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

#Simlinks go here too
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

echo "Adding tab completion to bash environment"
src="source /usr/local/bin/.vsim-completion.sh"

bashrc="$HOME/.bashrc"
if ! [ -f "$bashrc" ];then touch "$bashrc";fi
if ! cat "$bashrc" | grep "$src";then	echo "$src" >> "$bashrc";fi

echo "Adding tab completion to zsh environment"
zshrc="$HOME/.zshrc"
if ! [ -f "$zshrc" ];then touch "$zshrc";fi
if ! cat "$zshrc" | grep "compinit";then echo "autoload -U +X compinit && compinit" >> "$zshrc";fi
if ! cat "$zshrc" | grep "bashcompinit";then echo "autoload -U +X bashcompinit && bashcompinit" >> "$zshrc";fi
if ! cat "$zshrc" | grep "$src";then echo "$src" >> "$zshrc";fi

echo "Creating $HOME/vsims directories"
mkdir -p "$HOME/vsims"
chmod -R 777 "$HOME/vsims"
mkdir -p "$HOME/vsims/ontap"
chmod -R 777 "$HOME/vsims/ontap"

#Build templates if necessary
#Build standard.tgz from the ova
if ! [ -f "standard.tgz" ];then
	echo "Building standard diskmodel template."
	./vsim delete standard
	./vsim import -file "$ovafile" -name "standard"
  ./vsim export -vsim standard -image image1
  ./vsim import 991_sim_nodar_image.tgz
  ./vsim clean standard
	echo "Exporting tgz"
	./vsim export standard -tgz
	./vsim delete standard
fi

license_file="CMode_licenses_9.9.1.txt"
mkdir -p "$HOME/vsims/cfcard"
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


#image.tgz files go here:
mkdir -p /Library/WebServer/Documents/ontap
#or here
mkdir -p "$HOME/vsims/ontap"
mkdir -p "$HOME/vsims/cfcard"

failed=0
if ! [ -f "/usr/local/bin/vsim" ]; then failed=1;fi
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
vsimhome="$HOME/vsims"
./vsim options FODDIR "$vsimhome"



#orient the user
echo ""
echo "*************************************"
echo ""
echo "vsim installed."
echo "run vsim from the terminal for usage"
echo ""
echo "vsims will be placed in $vsimhome"
echo ""
echo "Open a new terminal window to proceed"
echo ""
echo "*************************************"
echo ""

exit
