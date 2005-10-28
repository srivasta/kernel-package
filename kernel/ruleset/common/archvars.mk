######################### -*- Mode: Makefile-Gmake -*- ########################
## archvars.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:19:59 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Fri Oct 28 00:22:13 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 4
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: 7b3be6bd-fec5-43ec-a974-6facbfab6950
## 
###############################################################################


DPKG_ARCH := dpkg-architecture

ifeq ($(strip $(KPKG_ARCH)),um)
  MAKING_VIRTUAL_IMAGE:=YES
endif
ifeq ($(strip $(KPKG_ARCH)),xen)
  MAKING_VIRTUAL_IMAGE:=YES
endif

ifdef KPKG_ARCH
  ifneq ($(strip $(KPKG_ARCH)),powerpc64)
    ifeq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
      ha:=-a$(KPKG_ARCH)
    endif
  endif
endif

# set the dpkg-architecture vars
export DEB_BUILD_ARCH      := $(shell $(DPKG_ARCH)       -qDEB_BUILD_ARCH)
export DEB_BUILD_GNU_CPU   := $(shell $(DPKG_ARCH)       -qDEB_BUILD_GNU_CPU)
export DEB_BUILD_GNU_SYSTEM:= $(shell $(DPKG_ARCH)       -qDEB_BUILD_GNU_SYSTEM)
export DEB_BUILD_GNU_TYPE  := $(shell $(DPKG_ARCH)       -qDEB_BUILD_GNU_TYPE)
export DEB_HOST_ARCH       := $(shell $(DPKG_ARCH) $(ha) -qDEB_HOST_ARCH)
export DEB_HOST_ARCH_OS    := $(shell $(DPKG_ARCH) $(ha) -qDEB_HOST_ARCH_OS      \
                                2>/dev/null|| true)
export DEB_HOST_ARCH_CPU   := $(shell $(DPKG_ARCH) $(ha) -qDEB_HOST_ARCH_CPU     \
                                2>/dev/null|| true)
export DEB_HOST_GNU_CPU    := $(shell $(DPKG_ARCH) $(ha) -qDEB_HOST_GNU_CPU)
export DEB_HOST_GNU_SYSTEM := $(shell $(DPKG_ARCH) $(ha) -qDEB_HOST_GNU_SYSTEM)
export DEB_HOST_GNU_TYPE   := $(shell $(DPKG_ARCH) $(ha) -qDEB_HOST_GNU_TYPE)

# arrgh. future proofing
ifeq ($(DEB_HOST_GNU_SYSTEM), linux)
  DEB_HOST_GNU_SYSTEM=linux-gnu
endif
ifeq ($(DEB_HOST_ARCH_OS),)
  ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
    DEB_HOST_ARCH_OS := linux
  endif
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
    DEB_HOST_ARCH_OS := kfreebsd
  endif
endif

REASON = @if [ -f $@ ]; then \
 echo "====== making $(notdir $@) because of $(notdir $?) ======";\
 else \
   echo "====== making (creating) $@ ======"; \
 fi

OLDREASON = @if [ -f $@ ]; then \
 echo "====== making $(notdir $@) because of $(notdir $?) ======";\
 else \
   echo "====== making (creating) $(notdir $@) ======"; \
 fi

LIBREASON = @echo "====== making $(notdir $@)($(notdir $%))because of $(notdir $?)======"
