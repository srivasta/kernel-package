######################### -*- Mode: Makefile-Gmake -*- ########################
## architecture.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:28:13 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Fri Oct 28 00:28:40 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
##
## arch-tag: ceaf3617-cfb1-4acb-a865-a87f280b2336
##
###############################################################################


######################################################################
###          Architecture specific stuff                           ###
######################################################################
# Each architecture has the following specified for it
# (a) The kernel image type (i.e. zImage or bzImage)
# (b) The dependency on a loader, if any
# (c) The name of the loader
# (d) The name of the documentation file for the loader
# (e) The build target
# (f) The location of the kernelimage source
# (g) The location of the kernelimage destination
# (h) The name of the arch specific configuration file
# Some architectures has sub architectures

### m68k
ifeq ($(strip $(architecture)),m68k)
  ifeq (,$(findstring /$(KPKG_SUBARCH)/,/amiga/atari/mac/mvme147/mvme16x/bvme6000/))
    GUESS_SUBARCH:=$(shell awk '/Model/ { print $$2}' /proc/hardware)
    ifneq (,$(findstring Motorola,$(GUESS_SUBARCH)))
     GUESS_SUBARCH:=$(shell awk '/Model/ { print $$3}' /proc/hardware)
     ifneq (,$(findstring MVME147,$(GUESS_SUBARCH)))
      KPKG_SUBARCH:=mvme147
     else
      KPKG_SUBARCH:=mvme16x
     endif
    else
     ifneq (,$(findstring BVME,$(GUESS_SUBARCH)))
      KPKG_SUBARCH:=bvme6000
     else
      ifneq (,$(findstring Amiga,$(GUESS_SUBARCH)))
       KPKG_SUBARCH:=amiga
      else
       ifneq (,$(findstring Atari,$(GUESS_SUBARCH)))
        KPKG_SUBARCH:=atari
       else
        ifneq (,$(findstring Mac,$(GUESS_SUBARCH)))
         KPKG_SUBARCH:=mac
        endif
       endif
      endif
     endif
    endif
  endif
  NEED_DIRECT_GZIP_IMAGE=NO
  kimage := zImage
  target = $(kimage)
  kimagesrc = vmlinux.gz
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  DEBCONFIG = $(CONFDIR)/config.$(KPKG_SUBARCH)
  ifneq (,$(findstring $(KPKG_SUBARCH),mvme147 mvme16x bvme6000))
    loaderdep=vmelilo
    loader=vmelilo
    loaderdoc=VmeliloDefault
  else
    loaderdep=
    loader=lilo
    loaderdoc=
  endif
endif

### ARM
ifeq ($(strip $(architecture)),arm)
  GUESS_SUBARCH:='netwinder'

  ifneq (,$(findstring $(KPKG_SUBARCH),netwinder))
    KPKG_SUBARCH:=$(GUESS_SUBARCH)
    kimage := zImage
    target = Image
    kimagesrc = arch/$(KERNEL_ARCH)/boot/Image
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    loaderdep=
    loader=nettrom
    loaderdoc=
    NEED_DIRECT_GZIP_IMAGE=NO
    DEBCONFIG= $(CONFDIR)/config.netwinder
  else
    kimage := zImage
    target = zImage
    NEED_DIRECT_GZIP_IMAGE=NO
    kimagesrc = arch/$(KERNEL_ARCH)/boot/zImage
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    DEBCONFIG = $(CONFDIR)/config.arm
  endif
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
endif

##### PowerPC64
ifneq ($(strip $(filter ppc64 powerpc64,$(architecture))),)
  kimage := vmlinux
  kimagesrc = vmlinux
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
  loader=NoLoader
  ifneq (,$(findstring $(KPKG_SUBARCH), powerpc powerpc64))
    ifneq (,$(findstring $(KPKG_SUBARCH), powerpc64))
      KERNEL_ARCH:=ppc64
    endif
    ifneq (,$(findstring $(KPKG_SUBARCH), powerpc))
      KERNEL_ARCH:=ppc
      NEED_IMAGE_POST_PROCESSING = YES
      IMAGE_POST_PROCESS_TARGET := mkvmlinuz_support_install
      IMAGE_POST_PROCESS_DIR    := arch/ppc/boot
      INSTALL_MKVMLINUZ_PATH = $(SRCTOP)/$(IMAGE_TOP)/usr/lib/kernel-image-${version}
    endif
    target := zImage
    loaderdep=mkvmlinuz
  else
    KERNEL_ARCH=ppc64
    target = $(kimage)
    kelfimagesrc  = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  endif
endif

### PowerPC
ifneq ($(strip $(filter ppc powerpc,$(architecture))),)
  ifeq ($(DEB_BUILD_ARCH),powerpc)
  # This is only meaningful when building on a PowerPC
    ifeq ($(GUESS_SUBARCH),)
      GUESS_SUBARCH:=$(shell awk '/machine/ { print $$3}' /proc/cpuinfo)
      ifneq (,$(findstring Power,$(GUESS_SUBARCH)))
        GUESS_SUBARCH:=pmac
      else
        # At the request of Colin Watson, changed from find string iMac.
        # Any powerpc system that would contain  Mac in /proc/cpuinfo is a
        # PowerMac system, according to arch/ppc/platforms/* in the kernel source
        ifneq (,$(findstring Mac,$(GUESS_SUBARCH)))
          GUESS_SUBARCH:=pmac
        endif
      endif
    else
      GUESS_SUBARCH:=pmac
    endif
    # Well NuBus powermacs are not pmac subarchs, but nubus ones.
    #ifeq (,$(shell grep NuBus /proc/cpuinfo))
    #  GUESS_SUBARCH:=nubus
    #endif
  endif

  ifeq (,$(findstring $(KPKG_SUBARCH),apus prpmc chrp mbx pmac prep Amiga APUs CHRP MBX PReP chrp-rs6k nubus powerpc powerpc64 ))
    KPKG_SUBARCH:=$(GUESS_SUBARCH)
  endif

  KERNEL_ARCH:=ppc

  ifneq (,$(findstring $(KPKG_SUBARCH), powerpc powerpc64))
    ifneq (,$(findstring $(KPKG_SUBARCH), powerpc64))
      KERNEL_ARCH:=ppc64
    endif
    ifneq (,$(findstring $(KPKG_SUBARCH), powerpc))
      KERNEL_ARCH:=ppc
      NEED_IMAGE_POST_PROCESSING = YES
      IMAGE_POST_PROCESS_TARGET := mkvmlinuz_support_install
      IMAGE_POST_PROCESS_DIR    := arch/ppc/boot
      INSTALL_MKVMLINUZ_PATH = $(SRCTOP)/$(IMAGE_TOP)/usr/lib/kernel-image-${version}
    endif
    target := zImage
    loaderdep=mkvmlinuz
    kimagesrc = vmlinux
    kimage := vmlinux
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
    DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH),APUs apus Amiga))
    KPKG_SUBARCH:=apus
    loader := NoLoader
    kimage := vmapus.gz
    target = zImage
    kimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/boot/images ]; then \
	echo arch/$(KERNEL_ARCH)/boot/images/vmapus.gz ; else \
	echo arch/$(KERNEL_ARCH)/boot/$(kimage) ; fi)
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
    DEBCONFIG = $(CONFDIR)/config.apus
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH),chrp-rs6k))
    KPKG_SUBARCH:=chrp-rs6k
    loaderdep=quik
    loader=quik
    loaderdoc=QuikDefault
    kimage := zImage
    target = $(kimage)
    kimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/chrpboot ]; then \
	echo arch/$(KERNEL_ARCH)/chrpboot/$(kimage) ; else \
	echo arch/$(KERNEL_ARCH)/boot/images/$(kimage).chrp-rs6k ; fi)
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
    DEBCONFIG = $(CONFDIR)/config.chrp
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH),CHRP chrp))
    KPKG_SUBARCH:=chrp
    loaderdep=quik
    loader=quik
    loaderdoc=QuikDefault
    kimage := zImage
    target = $(kimage)
    kimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/chrpboot ]; then \
         echo arch/$(KERNEL_ARCH)/chrpboot/$(kimage) ; else \
         echo arch/$(KERNEL_ARCH)/boot/images/$(kimage).chrp ; fi)
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
    DEBCONFIG = $(CONFDIR)/config.chrp
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH),PRPMC prpmc))
    KPKG_SUBARCH:=prpmc
    loader := NoLoader
    kimage := zImage
    target = $(kimage)
    kimagesrc = arch/$(KERNEL_ARCH)/boot/images/zImage.pplus
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH),MBX mbx))
    KPKG_SUBARCH:=mbx
    loader := NoLoader
    kimage := zImage
    target = $(kimage)
    kimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/mbxboot ]; then \
	echo arch/$(KERNEL_ARCH)/mbxboot/$(kimage) ; else \
	echo arch/$(KERNEL_ARCH)/boot/images/zvmlinux.embedded; fi)
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
    DEBCONFIG = $(CONFDIR)/config.mbx
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH),pmac))
    KPKG_SUBARCH:=pmac
    target := zImage
    ifeq ($(DEB_BUILD_ARCH),powerpc)
      # This is only meaningful when building on a PowerPC
      ifneq (,$(shell grep NewWorld /proc/cpuinfo))
        loaderdep=yaboot
        loader=yaboot
        #loaderdoc=
      else
        loaderdep=quik
        loader=quik
        loaderdoc=QuikDefault
      endif
    else
      loaderdep=yaboot
      loader=yaboot
    endif
    kimagesrc = vmlinux
    kimage := vmlinux
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
    HAVE_COFF_IMAGE = YES
    coffsrc = $(shell if [ -d arch/$(KERNEL_ARCH)/coffboot ]; then \
         echo arch/$(KERNEL_ARCH)/coffboot/$(kimage).coff ; else \
         echo arch/$(KERNEL_ARCH)/boot/images/$(kimage).coff ; fi)
    coffdest=$(INT_IMAGE_DESTDIR)/vmlinux.coff-$(version)
    DEBCONFIG = $(CONFDIR)/config.pmac
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH),PReP prep))
    KPKG_SUBARCH:=prep
    loader := NoLoader
    kimage := zImage
    target = $(kimage)
    kimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/boot/images ]; then \
         echo arch/$(KERNEL_ARCH)/boot/images/$(kimage).prep ; else \
         echo arch/$(KERNEL_ARCH)/boot/$(kimage) ; fi)
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
    DEBCONFIG = $(CONFDIR)/config.prep
  endif

  ifneq (,$(findstring $(KPKG_SUBARCH), NuBuS nubus))
    KPKG_SUBARCH := nubus
    target := zImage
    loader= NoLoader
    kimagesrc = arch/$(KERNEL_ARCH)/appleboot/Mach\ Kernel
    kimage := vmlinux
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  endif

endif


##### Alpha
ifeq ($(strip $(architecture)),alpha)
  kimage := vmlinuz
  loaderdep=
  loader=milo
  loaderdoc=
  target = boot
  kimagesrc = arch/$(KERNEL_ARCH)/boot/vmlinux.gz
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  DEBCONFIG = $(CONFDIR)/config.alpha
endif


##### Sparc
ifeq ($(strip $(architecture)),sparc)
  kimage := vmlinuz
  loaderdep = silo
  loader = silo
  loaderdoc=SiloDefault
  NEED_DIRECT_GZIP_IMAGE = YES
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  DEBCONFIG = $(CONFDIR)/config.sparc
  ifeq (,$(APPEND_TO_VERSION))
    ARCH_IN_NAME = YES
  endif

  ifeq (,$(KPKG_SUBARCH))
    ifeq (sparc64,$(strip $(shell uname -m)))
      KPKG_SUBARCH = sparc64
    else
      KPKG_SUBARCH = sparc32
    endif
  endif

  ifneq (,$(filter sparc64%,$(KPKG_SUBARCH)))
     KERNEL_ARCH = sparc64
  else
     ifneq (,$(filter sparc%,$(KPKG_SUBARCH)))
        KERNEL_ARCH = sparc
     else
        KERNEL_ARCH = $(strip $(shell uname -m))
     endif
  endif

  ifneq ($(shell if [ $(VERSION)  -ge  2 ] && [ $(PATCHLEVEL) -ge 5 ] &&  \
                    [ $(SUBLEVEL) -ge 41 ]; then echo new; \
               elif [ $(VERSION)  -ge  2 ] && [ $(PATCHLEVEL) -ge 6 ]; then \
                                            echo new; \
               elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
    target    = image
    kimagesrc = arch/$(KERNEL_ARCH)/boot/image
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  else
    target    = vmlinux
    kimagesrc = vmlinux
  endif
endif

##### amd64
ifeq ($(strip $(architecture)),amd64)
  KERNEL_ARCH=x86_64
  kimage := bzImage
  loaderdep=lilo (>= 19.1) | grub
  loader=lilo
  loaderdoc=LiloDefault
  target = $(kimage)
  kimagesrc = $(strip arch/$(KERNEL_ARCH)/boot/$(kimage))
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
endif


##### i386 and such
ifeq ($(strip $(architecture)),i386)
  # sub archs can be i386 i486 i586 i686
  GUESS_SUBARCH:=$(shell if test -f .config; then \
                        perl -nle '/^CONFIG_M(.86)=y/ && print "$$1"' .config;\
                       else \
                         uname -m;\
                       fi)
  ifeq (,$(findstring $(KPKG_SUBARCH),i386 i486 i586 i686))
    KPKG_SUBARCH:=$(GUESS_SUBARCH)
  endif
  DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
  ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
    kimage := bzImage
    loaderdep=lilo (>= 19.1) | grub
    loader=lilo
    loaderdoc=LiloDefault
    target = $(kimage)
    kimagesrc = $(strip arch/$(KERNEL_ARCH)/boot/$(kimage))
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
    kelfimagesrc = vmlinux
    kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  else
    loaderdep=grub | grub2
    loader=grub
    ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
      kimagesrc = $(strip $(KERNEL_ARCH)/compile/GENERIC/kernel)
      kimagedest = $(INT_IMAGE_DESTDIR)/kfreebsd-$(version)
    endif
  endif
endif

##### S/390
ifeq ($(strip $(architecture)),s390)
  # make it possible to build s390x kernels on s390 for 2.4 kernels only
  # because 2.6 always use s390 as architecture.
  ifeq (4,$(PATCHLEVEL))
    ifeq (,$(findstring $(KPKG_SUBARCH),s390 s390x))
      KPKG_SUBARCH = s390
    endif
    KERNEL_ARCH = $(KPKG_SUBARCH)
    ifneq ($(shell uname -m),$(KPKG_SUBARCH))
      UNAME_MACHINE = $(KPKG_SUBARCH)
      export UNAME_MACHINE
    endif
  endif
  kimage := zimage
  loaderdep=zipl
  loader=zipl
  loaderdoc=
  target = image
  NEED_DIRECT_GZIP_IMAGE=NO
  kimagesrc = $(strip arch/$(KERNEL_ARCH)/boot/$(target))
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
endif

##### hppa
ifeq ($(strip $(architecture)),hppa)
  kimage := vmlinux
  loaderdep=palo
  loader=palo
  loaderdoc=
  target=$(kimage)
  NEED_DIRECT_GZIP_IMAGE=NO
  # Override arch name because hppa uses arch/parisc not arch/hppa
  KERNEL_ARCH := parisc
  kimagesrc=$(kimage)
  kimagedest=$(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  # This doesn't seem to work, but the other archs do it...
  DEBCONFIG=$(CONFDIR)/config.$(KPKG_SUBARCH)
endif

##### ia64
ifeq ($(strip $(architecture)),ia64)
  kimage := vmlinuz
  loaderdep=elilo
  loader=elilo
  loaderdoc=
  target=compressed
  NEED_DIRECT_GZIP_IMAGE=NO
  kimagesrc=vmlinux.gz
  kimagedest=$(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  DEBCONFIG=$(CONFDIR)/config.$(KPKG_SUBARCH)
endif

##### mips
ifeq ($(strip $(architecture)),mips)
  # SGI ELF32: 64bit kernel, but firmware needs ELF32 for netboot
  # (the on-disk loader could do both).
  ifneq (,$(filter r4k-ip22 r5k-ip22 r5k-ip32 r10k-ip32,$(strip $(KPKG_SUBARCH))))
  ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ] &&    \
                    [ $(SUBLEVEL) -ge 11 ]; then echo new;                   \
               elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 7 ]; then \
                                            echo new;                        \
               elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
    kimage := vmlinux.32
  else
    kimage := vmlinux
  endif
    loaderdep = arcboot
    loader = arcboot
    loaderdoc =
  endif
  # SGI ELF64
  ifneq (,$(filter r10k-ip27 r10k-ip28 r10k-ip30,$(strip $(KPKG_SUBARCH))))
  # pre 2.6.11 the image name was vmlinux.64
  ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ] &&    \
                    [ $(SUBLEVEL) -ge 11 ]; then echo new;                   \
               elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 7 ]; then \
                                            echo new;                        \
               elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
    kimage := vmlinux
  else
    kimage := vmlinux.64
  endif
    loaderdep = arcboot
    loader = arcboot
    loaderdoc =
  endif
  # Broadcom SWARM
  ifneq (,$(filter sb1-swarm-bn,$(strip $(KPKG_SUBARCH))))
    loaderdep = sibyl
    loader = sibyl
    loaderdoc =
  endif

  # Default value
  ifeq (,$(kimage))
    kimage := vmlinux
  endif
  ifeq (,$(kimagesrc))
    kimagesrc := $(kimage)
  endif

  NEED_DIRECT_GZIP_IMAGE = NO
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)

  ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 5 ] &&    \
                    [ $(SUBLEVEL) -ge 41 ]; then echo new;                   \
               elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ]; then \
                                            echo new;                        \
               elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
    target =
  else
    target = boot
  endif

  ifneq (,$(filter mips64%,$(KPKG_SUBARCH)))
    KERNEL_ARCH = mips64
  endif
  ifneq (,$(filter %-64,$(KPKG_SUBARCH)))
    KERNEL_ARCH = mips64
  endif
endif

##### mipsel
ifeq ($(strip $(architecture)),mipsel)
  # DECstations
  ifneq (,$(filter r3k-kn02 r4k-kn04,$(strip $(KPKG_SUBARCH))))
    loaderdep = delo
    loader = delo
    loaderdoc =
  endif
  # Cobalt
  ifneq (,$(filter r5k-cobalt,$(strip $(KPKG_SUBARCH))))
    loaderdep = colo
    loader = colo
    loaderdoc =
  endif
  # LASAT
  ifneq (,$(filter r5k-lasat,$(strip $(KPKG_SUBARCH))))
    loaderdep =
    loader =
    loaderdoc =
  endif
  # Broadcom SWARM
  ifneq (,$(filter sb1-swarm-bn,$(strip $(KPKG_SUBARCH))))
    loaderdep = sibyl
    loader = sibyl
    loaderdoc =
  endif
  # xxs1500
  ifneq (,$(filter xxs1500,$(strip $(KPKG_SUBARCH))))
    kimage := vmlinux
    kimagesrc = $(strip arch/$(KERNEL_ARCH)/boot/$(kimage).srec)
    loaderdep =
    loader =
    loaderdoc =
  endif

  # Default value
  ifeq (,$(kimage))
    kimage := vmlinux
  endif
  ifeq (,$(kimagesrc))
    kimagesrc := $(kimage)
  endif

  NEED_DIRECT_GZIP_IMAGE = NO
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)

  ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 5 ] &&    \
                    [ $(SUBLEVEL) -ge 41 ]; then echo new;                   \
               elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ]; then \
                                            echo new;                        \
               elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
    target =
  else
    target = boot
  endif

  KERNEL_ARCH = mips
  ifneq (,$(filter mips64el%,$(KPKG_SUBARCH)))
    KERNEL_ARCH = mips64
  endif
  ifneq (,$(filter %-64,$(KPKG_SUBARCH)))
    KERNEL_ARCH = mips64
  endif
endif

##### m32r
ifeq ($(strip $(architecture)),m32r)
  KERNEL_ARCH := m32r
  kimage := zImage
  loaderdep=
  loader=
  loaderdoc=
  target = $(kimage)
  kimagesrc = $(strip arch/$(KERNEL_ARCH)/boot/$(kimage))
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
endif


# usermode linux
ifeq ($(strip $(architecture)),um)
  DEBCONFIG = $(CONFDIR)/config.um


  ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ] &&    \
                    [ $(SUBLEVEL) -ge 9 ]; then echo new;                   \
               elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge r ]; then \
                                            echo new;                        \
               elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
    target  = vmlinux
    kimage := vmlinux
  else
    target  = linux
    kimage := linux
  endif


  kimagesrc  = $(strip $(kimage))
  INT_IMAGE_DESTDIR=$(IMAGE_DOC)
  kimagedest = debian/tmp-image$(IMAGEDIR)/linux-$(version)
  loaderdep=
  loaderdoc=
  KERNEL_ARCH = um
  architecture = i386
  IMAGEDIR = /usr/bin
endif

# xen-linux
ifeq ($(strip $(architecture)),xen)
  KERNEL_ARCH = xen
  architecture = i386

  ifeq (,$(findstring $(KPKG_SUBARCH),xen0 xenu))
       KPKG_SUBARCH:=xen0
  endif
  DEBCONFIG = $(CONFDIR)/config.$(KPKG_SUBARCH)

  ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 5 ] &&    \
                    [ $(SUBLEVEL) -ge 41 ]; then echo new;                   \
               elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ]; then \
                                            echo new;                        \
               elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
    target    = vmlinuz
  else
    target    = bzImage
  endif
  kimage := $(target)

  ifeq (,$(filter xen0,$(KPKG_SUBARCH)))
     # only domain-0 are bootable via xen so only domain0 subarch needs grub and xen-vm
     loaderdep=grub,xen-vm
     loader=grub
     loaderdoc=
  else
     loaderdep=
     loader=
     loaderdoc=
  endif

  kimagesrc = $(kimage)
  kimagedest = $(INT_IMAGE_DESTDIR)/xen-linux-$(version)
endif

