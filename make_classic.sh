#!/bin/bash

# this script constructs a clean classic diskmodel VM template
# An original vsim-DOT805-7m.zip file must be provided
# This template is required to run versions of ONTAP older than 8.1.1
# 
# Because this file is no longer available these components are now optional
# and this script has not been ported to Linux

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


if [ $errCount -ne 0 ];then 
	echo
	echo "!!Dependency check failed!!"
	exit 1
fi
echo "Proceeding."
echo
echo "Checking components:"
if [ -f "classic.tgz" ];then
		echo "  classic.tgz............OK"; else
		echo "  classic.tgz............MISSING";fi
if [ -f "vsim-DOT805-7m.zip" ];then
		echo "  vsim-DOT805-7m.zip.....OK"; else
		echo "  vsim-DOT805-7m.zip.....MISSING";fi
echo
echo

if ! [ -f ] 

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

failed=0
if ! [ -f "$HOME/vsims/classic.tgz" ];then failed=1;fi

if [ $failed -ne 0 ];then 
	echo "File copy failed.  try again with sudo."
	exit
fi

echo "script installation succeeded."
echo ""


