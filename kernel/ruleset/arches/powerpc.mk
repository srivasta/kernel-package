######################### -*- Mode: Makefile-Gmake -*- ########################
## ppc.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:31:06 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Apr 13 09:58:30 2006
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 8
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: d59ba6c1-4d5e-46c2-aa8f-8c6e1d4a487b
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

# We need to set the KERNEL_ARCH depending on the actual version, so
# let's distinguish between pre-2.6.15, 2.6.15 and 2.6.14.
KERNEL_ARCH_VERSION = $(shell if [ $(VERSION) -lt 2 ]; then             \
                        echo pre-2.6.15;                                \
        elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -lt 6 ]; then      \
                        echo pre-2.6.15;                                \
        elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -eq 6 ] &&         \
                [ $(SUBLEVEL) -lt 15 ]; then                            \
                        echo pre-2.6.15;                                \
        elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -eq 6 ] &&         \
                [ $(SUBLEVEL) -lt 16 ]; then                            \
                        echo 2.6.15;                                    \
        else                                                            \
                        echo post-2.6.15;                               \
        fi)

# prpmc and mbx are not guessed automatically yet.
ifneq ($(strip $(filter ppc powerpc ppc64 powerpc64,$(DEB_BUILD_ARCH))),)
# This is only meaningful when building on a PowerPC
  ifeq ($(GUESS_SUBARCH),)
    GUESS_MACHINE:=$(shell awk '/machine/ { print $$3}' /proc/cpuinfo)
    GUESS_CPU:=$(shell awk '/cpu/ { print $$3}' /proc/cpuinfo)
    GUESS_GENERATION:=$(shell awk '/generation/ { print $$3}' /proc/cpuinfo)
    ifneq (,$(findstring POWER,$(GUESS_CPU)))
      GUESS_SUBARCH:=powerpc64
    else
      ifneq (,$(findstring PPC970,$(GUESS_CPU)))
        GUESS_SUBARCH:=powerpc64
      else
        ifneq (,$(findstring NuBus,$(GUESS_GENERATION)))
          GUESS_SUBARCH:=nubus
        else
          ifneq (,$(findstring Amiga,$(GUESS_MACHINE)))
            GUESS_SUBARCH:=apus
          endif
        endif
      endif
    endif
    ifeq ($(GUESS_SUBARCH),)
      ifeq ($(KERNEL_ARCH_VERSION),post-2.6.15)
        GUESS_SUBARCH:=powerpc
      else
        GUESS_SUBARCH:=ppc
      endif
    endif
  else
    ifeq ($(KERNEL_ARCH_VERSION),post-2.6.15)
      GUESS_SUBARCH:=powerpc
    else
      GUESS_SUBARCH:=ppc
    endif
  endif
endif

ifeq (,$(findstring $(KPKG_SUBARCH), apus Amiga APUs nubus ppc ppc32 ppc64 powerpc powerpc32 powerpc64 prpmc mbx MBX))
  KPKG_SUBARCH:=$(GUESS_SUBARCH)
endif


# pre-2.6.15 uses ppc for 32bit and ppc64 for 64bit.
ifeq ($(KERNEL_ARCH_VERSION), pre-2.6.15)
  ifneq (,$(findstring $(KPKG_SUBARCH), ppc64 powerpc64))
    KERNEL_ARCH:=ppc64
  endif
  ifneq (,$(findstring $(KPKG_SUBARCH), apus Amiga APUs nubus ppc ppc32 powerpc powerpc32 prpmc mbx MBX))
    KERNEL_ARCH:=ppc
  endif
endif

# 2.6.15 uses ppc still for 32bit and powerpc for 64bit,
# but can also use powerpc for 32bit as an alternative.
ifeq ($(KERNEL_ARCH_VERSION),2.6.15)
  ifneq (,$(findstring $(KPKG_SUBARCH), ppc64 powerpc64 powerpc powerpc32))
    KERNEL_ARCH:=powerpc
  endif
  ifneq (,$(findstring $(KPKG_SUBARCH), apus Amiga APUs nubus ppc ppc32 prpmc mbx MBX))
    KERNEL_ARCH:=ppc
  endif
endif
# 2.6.16 and up use powerpc for all major subarches, we keep still ppc for
# obscure subarches though, will probably be changed in the future.
ifeq ($(KERNEL_ARCH_VERSION),post-2.6.15)
  ifneq (,$(findstring $(KPKG_SUBARCH), ppc ppc32 ppc64 powerpc64 powerpc powerpc32))
    KERNEL_ARCH:=powerpc
  endif
  ifneq (,$(findstring $(KPKG_SUBARCH), apus Amiga APUs nubus prpmc mbx MBX))
    KERNEL_ARCH:=ppc
  endif
endif

kimagesrc = vmlinux
kimage := vmlinux
kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
target := $(kimage)
DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)

# 32bit generic powerpc subarches.
ifneq (,$(findstring $(KPKG_SUBARCH), powerpc powerpc32 ppc ppc32 ppc64 powerpc64))
  KPKG_SUBARCH:=powerpc
  NEED_IMAGE_POST_PROCESSING = YES
  IMAGE_POST_PROCESS_TARGET := mkvmlinuz_support_install
  IMAGE_POST_PROCESS_DIR    := arch/$(KERNEL_ARCH)/boot
  # INSTALL_MKVMLINUZ_PATH = /usr/lib/kernel-image-${version}
  INSTALL_MKVMLINUZ_PATH = /usr/lib/$(INT_STEM)-image-${version}
  define DO_IMAGE_POST_PROCESSING
	if grep $(IMAGE_POST_PROCESS_TARGET) $(IMAGE_POST_PROCESS_DIR)/Makefile 2>&1 \
                >/dev/null; then                                                     \
          if [ "$(KERNEL_ARCH_VERSION" = "post-2.6.15" ]; then                       \
            $(MAKE) INSTALL_MKVMLINUZ=$(TMPTOP)$(INSTALL_MKVMLINUZ_PATH)             \
               ARCH=$(KERNEL_ARCH) $(IMAGE_POST_PROCESS_TARGET);                     \
          else                                                                       \
            $(MAKE) INSTALL_MKVMLINUZ=$(TMPTOP)$(INSTALL_MKVMLINUZ_PATH)             \
              ARCH=$(KERNEL_ARCH) -C $(IMAGE_POST_PROCESS_DIR)                       \
                $(IMAGE_POST_PROCESS_TARGET);                                        \
          fi;                                                                        \
        fi
  endef
  target := zImage
  loaderdep=mkvmlinuz
endif

# 64bit generic powerpc subarches.
ifneq (,$(findstring $(KPKG_SUBARCH), powerpc64 ppc64))
  KPKG_SUBARCH:=powerpc64
endif
# apus subarch
ifneq (,$(findstring $(KPKG_SUBARCH),APUs apus Amiga))
  KPKG_SUBARCH:=apus
endif
# nubus subarch
ifneq (,$(findstring $(KPKG_SUBARCH), NuBuS nubus))
  KPKG_SUBARCH := nubus
  KERNEL_ARCH:=ppc
  target := zImage
  kimagesrc = arch/$(KERNEL_ARCH)/appleboot/Mach\ Kernel
  kimage := vmlinux
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
endif
# prpmc subarch
ifneq (,$(findstring $(KPKG_SUBARCH),PRPMC prpmc))
  KPKG_SUBARCH:=prpmc
  target = zImage
  kelfimagesrc = arch/$(KERNEL_ARCH)/boot/images/zImage.pplus
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
endif
# mbx subarch
ifneq (,$(findstring $(KPKG_SUBARCH),MBX mbx))
  KPKG_SUBARCH:=mbx
  target = zImage
  kelfimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/mbxboot ]; then \
        echo arch/$(KERNEL_ARCH)/mbxboot/$(kimage) ; else            \
        echo arch/$(KERNEL_ARCH)/boot/images/zvmlinux.embedded; fi)
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
endif

#Local variables:
#mode: makefile
#End:
