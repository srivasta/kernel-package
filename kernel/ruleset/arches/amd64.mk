######################### -*- Mode: Makefile-Gmake -*- ########################
## amd64.mk ---
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com )
## Created On       : Mon Oct 31 18:31:11 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:18:47 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 6
## Status           : Unknown, Use with caution!
## HISTORY          :
## Description      : handle the architecture specific variables.
##
## arch-tag: 0429f056-d3a2-43d3-a02b-78bf0f655633
##
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
###############################################################################

IMAGE_SRC_DIR=$(shell if [ $(VERSION) -lt 2 ]; then                     \
                        echo $(KERNEL_ARCH);                            \
        elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -lt 6 ]; then      \
                        echo $(KERNEL_ARCH);                            \
        elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -eq 6 ] &&         \
                [ $(SUBLEVEL) -lt 26 ]; then                            \
                        echo $(KERNEL_ARCH);                            \
        else                                                            \
                        echo x86;                                       \
        fi)

KERNEL_ARCH=x86_64
ifeq ($(DEB_HOST_ARCH_OS), linux)
  kimage := bzImage
  target = $(kimage)
  kimagesrc = $(strip arch/$(IMAGE_SRC_DIR)/boot/$(kimage))
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
  DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
  ifeq ($(strip $(CONFIG_X86_64_XEN)),)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)
  else ifeq ($(strip $(CONFIG_XEN)),)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)
  else
    kelfimagesrc = vmlinux
    ifeq ($(strip $(CONFIG_XEN_PRIVILEGED_GUEST)),)
      kelfimagedest = $(INT_IMAGE_DESTDIR)/xenu-linux-$(KERNELRELEASE)
    else
      kelfimagesrc = $(INT_IMAGE_DESTDIR)/xen0-linux-$(KERNELRELEASE)
    endif
    int_install_vmlinux:=YES
  endif
endif

#Local variables:
#mode: makefile
#End:
