#!/bin/bash
errCount=0
if [[ $UID = 0 ]]; then
    echo "Please run this script without sudo"
    exit 1
fi

echo
echo "Checking dependencies."
#Make sure fusion is installed:
OVFTOOL="/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/ovftool"
VDISKMANAGER="/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
VMRUN="/Applications/VMware Fusion.app/Contents/Library/vmrun"
if ! [ -f "$OVFTOOL" ] || ! [ -f "$VDISKMANAGER" ] || ! [ -f "$VMRUN" ];then 
	echo
	echo "One or more VMware Fusion components were not found:"
	if ! [ -f "$OVFTOOL" ];then echo "missing: $OVFTOOL";((errCount++));fi
	if ! [ -f "$VDISKMANAGER" ];then echo "missing: $VDISKMANAGER";((errCount++));fi
	if ! [ -f "$VMRUN" ];then echo "missing: $VMRUN";((errCount++));fi
	echo "Install VMware Fusion and try the installation again."
fi


## makespare is no longer required
##
# if ! [ -f "makespare" ] || ! [ -f "makedisks" ]; then 
# 	if ! [ -f "7.3.6-tarfile-v22.tgz" ];then
# 		echo
# 		echo "Some files are required from the 7.3.6 simulator package."
# 		echo "Please download 7.3.6-tarfile-v22.tgz and place it in this"
# 		echo "folder, then try the installation again."
# 		echo
# 		echo "This file can be downloaded from mysupport.netapp.com at:"
# 		echo "http://mysupport.netapp.com/NOW/cgi-bin/simulatorlic.cgi/download/tools/simulator/ontap/7.3.6/7.3.6-tarfile-v22.tgz"
# 		((errCount++))
# 	fi
# fi

## standard.tgz construction has moved to install.sh
# ovafile=`ls vsim-netapp-DOT8.3*.ova | sort | head -1`
# if [ -z "$ovafile" ] && ! [ -f "standard.tgz" ];then 
# 		echo "An existing 8.3.x VSim OVA file is required."
# 		echo "Plase download the workstation version and place it in this"
# 		echo "folder, then try the installation again."
# 		((errCount++))
# fi

# if [ -z "$ovafile" ] && ! [ -f "vsim_makedisks" ];then 
# 		echo "An existing 8.3.x VSim OVA file is required."
# 		echo "Plase download the workstation version and place it in this"
# 		echo "folder, then try the installation again."
# 		((errCount++))
# fi

if [ $errCount -ne 0 ];then 
	echo
	echo "!!Dependency check failed!!"
	echo "!!Installation cancelled!!"
	exit 1
fi
echo "Proceeding."
echo
echo "Checking components:"
# if [ -f "makepare" ];then 
# 		echo "  makespare.......OK"; else 
# 		echo "  makespare.......MISSING";fi
# if [ -f "makedisks" ];then
# 		echo "  makedisks.......OK"; else
# 		echo "  makedisks.......MISSING";fi
# if [ -f "vsim_makedisks" ];then
# 		echo "  vsim_makedisks..OK"; else
# 		echo "  vsim_makedisks..MISSING";fi
if [ -f "standard.tgz" ];then
		echo "  standard.tgz....OK"; else
		echo "  standard.tgz....MISSING";fi
if [ -f "classic.tgz" ];then
		echo "  classic.tgz.....OK"; else
		echo "  classic.tgz.....MISSING";fi
echo
echo

## makespare is no longer required
##
#get some bits from 7.3.6
# if ! [ -f "makespare" ] || ! [ -f "makedisks" ]; then 
# 	if [ -f "7.3.6-tarfile-v22.tgz" ];then
# 		echo
# 		echo "Extracting components from 7.3.6-tarfile-v22.tgz"
# 		tar -xzvf 7.3.6-tarfile-v22.tgz simulator/sim.tgz
# 		tar -xzvf simulator/sim.tgz sim/makedisks
# 		tar -xzvf simulator/sim.tgz sim/makespare
# 		cp sim/makespare makespare
# 		cp sim/makedisks makedisks
# 		rm -rf sim
# 		rm -rf simulator
# 	fi
# fi

## standard.tgz is now built by install.sh
##
#Build standard.tgz from the ova
# if ! [ -f "standard.tgz" ];then 
# 	echo "Building standard diskmodel template."
# 	mkdir -p "$HOME/vsims"
# 	./vsim rm standard
# 	./vsim import -file "$ovafile" -name "standard"
# 	echo "Mounting CF Card"
# 	./vsim mount standard
# 	echo "Cleaning CF Card"
# 	rm "$HOME/vsims/standard/mnt/x86_64/freebsd/image1"/*.*
# 	rm "$HOME/vsims/standard/mnt/x86_64/freebsd/image2"/*.*
# 	echo "Unmounting"
# 	./vsim unmount standard
# 	echo "Exporting tgz"
# 	./vsim maketgz standard
# 	./vsim rm standard
# fi

## vsim_makedisks is no longer required
##
# #recover vsim_makedisks
# if ! [ -f "vsim_makedisks" ];then
# 	echo "Retreiving vsim_makedisks."
# 	./vsim import -file "$ovafile" -name "standard"
# 	./vsim setenv "standard" "bootarg.setup.auto" "true" 
# 	./vsim setenv "standard" "bootarg.setup.auto.file" "/cfcard/auto.ngsh" 
# 	./vsim mount standard
# 	setupfile="$HOME/vsims/standard/mnt/auto.ngsh"
# 	echo "#!/bin/sh" > $setupfile
# 	echo "#Created by vsim4osx" >> $setupfile
# 	echo "" >> $setupfile
# 	echo "mkdir /cfcard/files" >> $setupfile
# 	echo "cp /usr/sbin/vsim_makedisks /cfcard/files" >> $setupfile
# 	echo "sudo kenv bootarg.vm.no_poweroff_on_halt=false" >> $setupfile
# 	echo "halt" >> $setupfile
# 	./vsim unmount standard
# 	./vsim makecons standard
# 	./vsim start standard
# 	vmx="$HOME/vsims/standard/DataONTAP.vmx"
# 	echo "wait 3 minutes"
# 	sleep 180s #FIXME - this lazy solution is probably fragile
# 	./vsim mount standard
# 	cp "$HOME/vsims/standard/mnt/files/vsim_makedisks" "vsim_makedisks"
# 	./vsim unmount standard
# 	./vsim rm standard
# fi

#if [ -f "vsim_makedisks" ];then echo "Success!";fi


echo "creating classic diskmodel template."
classic="vsim-DOT805-7m.zip"
./vsim rm classic
./vsim import -file "$classic" -name "classic"
echo "Mounting CF Card"
./vsim mount classic
echo "Cleaning CF Card"
rm "$HOME/vsims/classic/mnt/x86_64/freebsd/image1"/*.*
rm "$HOME/vsims/classic/mnt/x86_64/freebsd/image2"/*.*
echo "Unmounting"
./vsim unmount classic
echo "Purging golden images"
	vmdk="$HOME/vsims/classic/DataONTAP.vmdk"
	vmdkfile="$HOME/vsims/classic/DataONTAP-flat.vmdk"
	#If its not thick we must convert it
	if [ -f "$vmdk" ] && ! [ -f "$vmdkfile" ]; then
		rm "$HOME/vsims/classic/tmp.vmdk" 2>/dev/null
		rm "$HOME/vsims/classic/tmp-flat.vmdk" 2>/dev/null
		"$VDISKMANAGER" -n "$vmdk" "$HOME/vsims/classic/tmp.vmdk"
		"$VDISKMANAGER" -r "$HOME/vsims/classic/tmp.vmdk" -t 4 "$vmdk"
		rm "$HOME/vsims/classic/tmp.vmdk" 2>/dev/null
		rm "$HOME/vsims/classic/tmp-flat.vmdk" 2>/dev/null	
	fi

	#Rename file, create a mountpoint, and call hdiutil
	#hdiutil will only mount the filesystem if the file ends in .cdr
	mv "$vmdkfile" "$vmdkfile.cdr"
	mkdir "$HOME/vsims/classic/mnt" &> /dev/null
	hdiutil attach "$vmdkfile.cdr" -mountpoint "$HOME/vsims/classic/mnt" >/dev/null		

	#Now purge the images
	chflags nouchg "$HOME/vsims/classic/mnt/x86_64/freebsd/image1"/*.*
	chflags nouchg "$HOME/vsims/classic/mnt/x86_64/freebsd/image2"/*.*
	rm "$HOME/vsims/classic/mnt/x86_64/freebsd/image1"/*.*
	rm "$HOME/vsims/classic/mnt/x86_64/freebsd/image2"/*.*

	#And zero the empy sectors
	#Zero whitespace
	echo "zeroing unused blocks in $vmdkfile"
	ws=$(df "$HOME/vsims/classic/mnt" | grep / | tr -s ' ' | cut -d ' ' -f 4)
	dd if=/dev/zero of="$HOME/vsims/classic/mnt/zero.bin" bs=512 count=$ws &> /dev/null
	rm "$HOME/vsims/classic/mnt/zero.bin"

	#Now unmount
	#Clean up some OSX specific flotsam
	rm -rf "$HOME/vsims/classic/mnt/.T*"
	rm -rf "$HOME/vsims/classic/mnt/._*"
	rm -rf "$HOME/vsims/classic/mnt/.f*"
	
	#Clean up mountpoint and remove .cdr extention
	hdiutil detach "$HOME/vsims/classic/mnt"
	rm -rf "$HOME/vsims/classic/mnt"
	mv "$vmdkfile.cdr" "$vmdkfile"

	#And convert it back to thin/sparse
	rm "$HOME/vsims/classic/tmp.vmdk" 2>/dev/null
	rm "$HOME/vsims/classic/tmp-flat.vmdk" 2>/dev/null
	rm "$HOME/vsims/classic/tmp-"*.vmdk 2>/dev/null
	"$VDISKMANAGER" -n "$vmdk" "$HOME/vsims/classic/tmp.vmdk"
	"$VDISKMANAGER" -r "$HOME/vsims/classic/tmp.vmdk" -t 1 "$vmdk"
	rm "$HOME/vsims/classic/tmp.vmdk" 2>/dev/null
	rm "$HOME/vsims/classic/tmp-flat.vmdk" 2>/dev/null	
	rm "$HOME/vsims/classic/tmp-"*.vmdk 2>/dev/null



echo "Exporting tgz"
./vsim maketgz classic
./vsim rm classic

exit


#Plan is to dynamically build the standard.tgz/classic.tgz from these sources:
#810
#http://mysupport.netapp.com/NOW/cgi-bin/simulatorlic8.cgi/download/tools/simulator/ontap/8.1/vsim-DOT81-cm-esx.zip
#8.2.3
#http://mysupport.netapp.com/NOW/cgi-bin/simulatorlic8.cgi/download/tools/simulator/ontap/8.2.3/vsim_netapp-cm.tgz

#or here
# mkdir -p "$HOME/vsims/ontap"

failed=0
# if ! [ -f "/usr/local/bin/vsim" ]; then failed=1;fi
# if ! [ -f "/usr/local/bin/vsim_makedisks" ];then failed=1;fi
# if ! [ -f "/usr/local/bin/makespare" ];then failed=1;fi
# if ! [ -f "$HOME/vsims/standard.tgz" ];then failed=1;fi
if ! [ -f "$HOME/vsims/classic.tgz" ];then failed=1;fi

if [ $failed -ne 0 ];then 
	echo "File copy failed.  try again with sudo."
	exit
fi

echo "script installation succeeded."
echo ""


