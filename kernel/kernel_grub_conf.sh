#!/bin/bash
#                               -*- Mode: Sh -*- 
# kernel_grub_conf.sh --- 
# Author           : Junichi Uekawa <dancer@debian.org>
# Created On       : Fri Jan 19 12:25:31 2001
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Jul  4 22:21:15 2001
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 11
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# This script can be added to the kernel-img.conf postinst_hook
# variable to be executed on kernel image installs, and add that
# kernel image into the grub menu
# 
# A simple script like:
# perl -nle 'print unless /^#Autogenerated by kernel-image $version/
# .. /^#End kernel-image '$version/'
# or for awk fans
# awk 'BEGIN{printit=1} 
#      /^#Autogenerated by kernel-image $version/{printit=0}
#      /^#End kernel-image '$version/{printit=1}
#      {if (printit) {print}}'. 
# or
# awk '{p=0}/^#Autogenerated by kernel-image $version$/,/^#End kernel-image '$version$/{p=1}{if(!p) print}' < foo
# can be added to the postrm script to remove the lines added
# 
# A full featured script is provided in kernel_grub_rm.sh

# a quick hack to add a line to /boot/grub/menu.lst

CONFIG_FILE=/etc/kernel_grub.conf

### Defaults
grub_menu_lst=/boot/grub/menu.lst       # location of the file
grub_kernel_partition=(hd0,0)           # the partition in grubtalk
grub_root_partition=(hd0,0)             # the location of root filesystem.
# kernel_boot_options="hdc=ide-scsi"    # any options come here.

if [ -e $CONFIG_FILE ]; then
    source $CONFIG_FILE
fi

if [ $# -ne 2 ]; then
    echo Usage: $0 version location
    exit 2
fi

version="$1"
vmlinuz_location="$2"
##echo $grub_menu_lst

if [ -f $grub_menu_lst ]; then
  if grep "^kernel $grub_kernel_partition$vmlinuz_location"  $grub_menu_lst >/dev/null 2>&1; 
    then
	echo "Seems like this kernel (version $version) is already"
	echo "installed in $grub_menu_lst. Skipping"
    else
	echo Installing a new entry into menu $grub_menu_lst
	echo >> $grub_menu_lst 
	echo "#Autogenerated by kernel-image $version " >> $grub_menu_lst 
	echo title linux $version >> $grub_menu_lst
	echo root $grub_root_partition >> $grub_menu_lst
	echo kernel $grub_kernel_partition$vmlinuz_location $kernel_boot_options >> $grub_menu_lst
	echo "#End kernel-image $version " >> $grub_menu_lst 
    fi
fi

exit 0
