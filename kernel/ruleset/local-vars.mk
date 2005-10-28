######################### -*- Mode: Makefile-Gmake -*- ########################
## local-vars.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:37:02 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Fri Oct 28 08:25:28 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 4
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
##
## arch-tag: 429a30d9-86ea-4641-bae8-29988a017daf
##
###############################################################################


# Where we read our config information from
CONFLOC    :=$(shell if test -f ~/.kernel-pkg.conf; then \
                        echo ~/.kernel-pkg.conf;         \
                     else                                \
                        echo /etc/kernel-pkg.conf;       \
                     fi)
# Where the package libs are stored
LIBLOC     :=/usr/share/kernel-package
# Default location of the modules
ifeq ($(strip $(MODULE_LOC)),)
MODULE_LOC =/usr/src/modules
endif
#
DEBIAN_FILES = ChangeLog  Control  Control.bin86 config         
DEBIAN_DIRS  = Config docs examples ruleset scripts pkg

#  Package specific stuff
# decide if image is meant to be in /boot rather than /
link_in_boot :=
# Can we use symlinks?
no_symlink :=
# If so, where is the real file (usually, vmlinuz-X.X.X is real, and
# vmlinuz is the link, this variable reverses it.
reverse_symlink :=

# The version numbers for kernel-image, kernel-headers and
# kernel-source are deduced from the Makefile (see below,
# and footnote 1 for details)

# Whether to look for and install kernel patches by default.
# Be very careful if you do this.
patch_the_kernel := AUTO

# run make clean after build
do_clean := NO

# install uncompressed kernel ELF-image (for oprofile)
int_install_vmlinux := NO

# what kernel config target to run in our configure target.
config_target := oldconfig


# The default architecture (all if architecture independent)
CROSS_ARG:=


#
# VERSION=$(shell LC_ALL=C dpkg-parsechangelog | grep ^Version: | \
#                          sed 's/^Version: *//')
#


ifdef KPKG_ARCH
  architecture:=$(KPKG_ARCH)
else
  #architecture:=$(shell CC=$(HOSTCC) dpkg --print-gnu-build-architecture)
  #architecture:=$(DEB_HOST_ARCH)
  ifeq (,$(DEB_HOST_ARCH_CPU))
    architecture:=$(DEB_HOST_GNU_CPU)
  else
    architecture:=$(DEB_HOST_ARCH_CPU)
  endif
  ifeq ($(architecture), x86_64)
    architecture:=amd64
  endif
endif

ifndef CROSS_COMPILE
  ifneq ($(strip $(KPKG_ARCH)),powerpc64)
    ifeq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
      ifneq ($(strip $(architecture)),$(strip $(DEB_BUILD_ARCH)))
        #KERNEL_CROSS:=$(architecture)-$(strip $(DEB_HOST_ARCH_OS))-
        KERNEL_CROSS:=$(DEB_HOST_GNU_TYPE)-
        ifeq ($(architecture), amd64)
          KERNEL_CROSS:=$(architecture)-$(strip $(DEB_HOST_ARCH_OS))-
        endif
      endif
    endif
  endif
else
  KERNEL_CROSS:=$(CROSS_COMPILE)-
endif

KERNEL_CROSS:=$(shell echo $(KERNEL_CROSS) | sed -e 's,--$$,-,')

ifneq ($(strip $(KERNEL_CROSS)),)
  CROSS_ARG:=CROSS_COMPILE=$(KERNEL_CROSS)
endif

KERNEL_ARCH:=$(architecture)
DEBCONFIG = $(CONFDIR)/config
IMAGEDIR=/boot
INT_IMAGE_DESTDIR=debian/tmp-image$(IMAGEDIR)

comma:= ,
empty:=
space:= $(empty) $(empty)


ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
  PMAKE = PATH=/usr/lib/freebsd/:$(CURDIR)/bin:$(PATH) WERROR= MAKEFLAGS= freebsd-make
endif

# Install rules
install_file=    install -p    -o root -g root -m 644
install_program= install -p    -o root -g root -m 755
make_directory=  install -p -d -o root -g root -m 755

ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
  # localversion_files := $(wildcard localversion*)
  # VERSION =$(shell grep -E '^VERSION +=' Makefile 2>/dev/null | \
  #  sed -e 's/[^0-9]*\([0-9]*\)/\1/')
  # PATCHLEVEL =$(shell grep -E '^PATCHLEVEL +=' Makefile 2>/dev/null | \
  #  sed -e 's/[^0-9]*\([0-9]*\)/\1/')
  # SUBLEVEL =$(shell grep -E '^SUBLEVEL +=' Makefile 2>/dev/null | \
  #  sed -e 's/[^0-9]*\([0-9]*\)/\1/')
  # EXTRA_VERSION =$(shell grep -E '^EXTRAVERSION +=' Makefile 2>/dev/null | \
  #  sed -e 's/EXTRAVERSION *= *\([^ \t]*\)/\1/')
  # LOCALVERSION = $(subst $(space),, $(shell cat /dev/null $(localversion_files)) \
  #                  $(CONFIG_LOCALVERSION))

  # Could have used :=, but some patches do seem to patch the
  # Makefile. perhaps deferring the rule makes that better
  $(eval $(which_debdir))
  VERSION      :=$(shell $(MAKE) $(CROSS_ARG) --no-print-directory -sf            \
                         $(DEBDIR)/ruleset/kernel_version.mk debian_VERSION)
  PATCHLEVEL   :=$(shell $(MAKE) $(CROSS_ARG) --no-print-directory -sf            \
                         $(DEBDIR)/ruleset/kernel_version.mk debian_PATCHLEVEL)
  SUBLEVEL     :=$(shell $(MAKE) $(CROSS_ARG) --no-print-directory -sf            \
                         $(DEBDIR)/ruleset/kernel_version.mk debian_SUBLEVEL)
  EXTRA_VERSION:=$(shell $(MAKE) $(CROSS_ARG) --no-print-directory -sf            \
                         $(DEBDIR)/ruleset/kernel_version.mk debian_EXTRAVERSION)
  LOCALVERSION :=$(shell $(MAKE) $(CROSS_ARG) --no-print-directory -sf            \
                         $(DEBDIR)/ruleset/kernel_version.mk debian_LOCALVERSION)
else
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
    VERSION        =$(shell grep '^REVISION=' conf/newvers.sh |                   \
      sed -e 's/[^0-9]*\([0-9]\)\..*/\1/')
    PATCHLEVEL =$(shell grep '^REVISION=' conf/newvers.sh |                       \
     sed -e 's/[^0-9]*[0-9]*\.\([0-9]*\)[^0-9]*/\1/')
    SUBLEVEL =0
    EXTRA_VERSION =$(shell grep '^RELEASE=' conf/newvers.sh |                     \
     sed -e 's/[^0-9]*\([0-9]*\)[^0-9]*/\1/')
    LOCALVERSION = $(subst $(space),,                                             \
       $(shell cat /dev/null $(localversion_files)) $(CONFIG_LOCALVERSION))
  endif
endif

HAVE_NEW_MODLIB =$(shell grep -E '\(INSTALL_MOD_PATH\)' Makefile 2>/dev/null )

ifneq ($(strip $(EXTRA_VERSION)),)
HAS_ILLEGAL_EXTRA_VERSION =$(shell                                                  \
    perl -e '$$i="$(EXTRA_VERSION)"; $$i !~ m/^[a-z\.\-\+][a-z\d\.\-\+]*$$/o && print YES;')
  ifneq ($(strip $(HAS_ILLEGAL_EXTRA_VERSION)),)
    $(error Error: The EXTRAVERSION may only contain lowercase alphanumerics        \
 and  the  characters  - +  . The current value is: $(EXTRA_VERSION). Aborting.)
  endif
endif

# NOTE: FLAVOUR is now obsolete
# If you want to have more than one kernel configuration per kernel
# version, set FLAVOUR in the top level kernel Makefile *before*
# invoking make-kpkg -- it will be appended to UTS_RELEASE in
# version.h (separated by a hyphen). This affects everything -- the
# names and versions of the image, source, headers, and doc packages,
# and where the modules are searched for in /lib/modules.

ifdef FLAVOUR
# uhm - should check if we really have a Makefile capable of Flavours?
endif

FLAVOUR:=$(shell grep ^FLAVOUR Makefile 2>/dev/null | \
                  perl -ple 's/FLAVOUR[\s:=]+//g')

ifeq ($(strip $(FLAVOUR_SEP)),)
FLAVOUR_SEP:= +
endif

ifneq ($(strip $(FLAVOUR)),)
INT_FLAV := $(FLAVOUR_SEP)$(FLAVOUR)
FLAV_ARG := FLAVOUR=$(FLAVOUR)
else
INT_FLAV :=
FLAV_ARG :=
endif

## This is the replacement for FLAVOUR
EXTRAVERSION =$(strip $(EXTRA_VERSION))
ifneq ($(strip $(APPEND_TO_VERSION)),)
iatv := $(strip $(APPEND_TO_VERSION))
EXTRAV_ARG := EXTRAVERSION=${EXTRA_VERSION}${iatv}
else
iatv :=
EXTRAV_ARG :=
endif

UTS_RELEASE_VERSION=$(shell if [ -f include/linux/version.h ]; then                     \
                 grep 'define UTS_RELEASE' include/linux/version.h |                    \
                 perl -nle  'm/^\s*\#define\s+UTS_RELEASE\s+("?)(\S+)\1/g && print $$2;';\
                 else echo "" ;                                                         \
                 fi)

version = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)$(iatv)$(INT_FLAV)$(LOCALVERSION)

# Bug out if the version number id not all lowercase
lc_version = $(shell echo $(version) | tr A-Z a-z)
ifneq ($(strip $(version)),$(strip $(lc_version)))
  ifeq ($(strip $(IGNORE_UPPERCASE_VERSION)),)
    $(error Error. The version number $(strip $(version)) is not all \
 lowercase. Since the version ends up in the package name of the \
 kernel image package, this is a Debian policy violation, and \
 the packaging system shall refuse to package the image. )
  else
    $(warn Error. The version number $(strip $(version)) is not all \
 lowercase. Since the version ends up in the package name of the \
 kernel image package, this is a Debian policy violation, and \
 the packaging system shall refuse to package the image. Lower -casing version.)

    version := $(strip $(lc_version))
  endif
endif


AM_OFFICIAL := $(shell if [ -f debian/official ]; then echo YES; fi )

# Do the architecture specific variable setting here
include $(DEBDIR)/ruleset/architecture.mk


######################################################################
######################################################################

ifneq ($(strip $(KPKG_STEM)),)
INT_STEM := $(KPKG_STEM)
else
INT_STEM := $(DEB_HOST_ARCH_OS)
endif

ifneq ($(strip $(loaderdep)),)
  int_loaderdep := $(loaderdep),
else
  int_loaderdep :=
endif


# See if we are being run in the kernel directory
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
  IN_KERNEL_DIR := $(shell if test -d drivers && test -d kernel && test -d fs && test \
                                   -d include/linux ; then                            \
                                      echo YES;                                       \
                           fi )
else
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
    IN_KERNEL_DIR := $(shell if test -d dev && test -d kern && test -d fs &&          \
                             test -d i386/include ; then echo YES; fi)
  endif
endif

IN_KERNEL_HEADERS=$(shell if [ -f $(INT_STEM)-headers.revision ]; then                \
                               cat $(INT_STEM)-headers.revision;                      \
                            else echo "" ;                                            \
                            fi)

ifeq ($(strip $(IN_KERNEL_DIR)),)
ifneq ($(strip $(IN_KERNEL_HEADERS)),)
version=$(UTS_RELEASE_VERSION)
debian :=$(IN_KERNEL_HEADERS)
endif
endif

# KPKG_SUBARCH is used to distinguish Amiga, Atari, Macintosh, etc. kernels
# for Debian/m68k.  INT_SUBARCH is used in the names of the image file
# produced. It only affects the naming of the kernel-image as the
# source and doc packages are architecture independent and the
# kernel-headers do not vary from one sub-architecture to the next.

# This is the default
INT_SUBARCH :=

ifneq ($(strip $(ARCH_IN_NAME)),)
ifneq ($(strip $(KPKG_SUBARCH)),)
INT_SUBARCH := -$(KPKG_SUBARCH)
endif
endif

# The name of the package (for example, 'emacs').
package   := $(INT_STEM)-source-$(version)
h_package := $(INT_STEM)-headers-$(version)
ifeq ($(strip $(KERNEL_ARCH)),um)
	i_package := $(INT_STEM)-uml-$(version)$(INT_SUBARCH)
else
  ifeq ($(strip $(KERNEL_ARCH)),xen)
	i_package := $(INT_STEM)-$(KPKG_SUBARCH)-$(version)
  else
	i_package := $(INT_STEM)-image-$(version)$(INT_SUBARCH)
  endif
endif
d_package := $(INT_STEM)-doc-$(version)
m_package := $(INT_STEM)-manual-$(version)

SOURCE_TOP:= debian/tmp-source
HEADER_TOP:= debian/tmp-headers
IMAGE_TOP := debian/tmp-image
DOC_TOP   := debian/tmp-doc
MAN_TOP   := debian/tmp-man
MAN1DIR    = $(IMAGE_TOP)/usr/share/man/man1

SOURCE_DOC:= $(SOURCE_TOP)/usr/share/doc/$(package)
HEADER_DOC:= $(HEADER_TOP)/usr/share/doc/$(h_package)
IMAGE_DOC := $(IMAGE_TOP)/usr/share/doc/$(i_package)
DOC_DOC   := $(DOC_TOP)/usr/share/doc/$(d_package)
DOC_MAN   := $(DOC_TOP)/usr/share/man/man9
MAN_DOC   := $(MAN_TOP)/usr/share/doc/$(m_package)
MAN_MAN   := $(MAN_TOP)/usr/share/man/man9

SOURCE_SRC:= $(SOURCE_TOP)/usr/src/$(package)
HEADER_SRC:= $(HEADER_TOP)/usr/src/$(h_package)
UML_DIR   := $(IMAGE_TOP)/usr/lib/uml/modules-$(version)


FILES_TO_CLEAN  = modules/modversions.h modules/ksyms.ver debian/files \
                  conf.vars scripts/cramfs/cramfsck scripts/cramfs/mkcramfs \
                  applied_patches debian/buildinfo
STAMPS_TO_CLEAN = stamp-build stamp-configure stamp-source stamp-image \
                  stamp-headers stamp-src stamp-diff stamp-doc stamp-manual \
                  stamp-buildpackage stamp-debian \
                  stamp-patch stamp-kernel-configure
DIRS_TO_CLEAN   = $(SOURCE_TOP) $(HEADER_TOP) $(IMAGE_TOP) $(DOC_TOP)

ifeq ($(strip $(VERSIONED_PATCH_DIR)),)
VERSIONED_PATCH_DIR         = $(shell if [ -d \
/usr/src/kernel-patches/$(architecture)/$(VERSION).$(PATCHLEVEL).$(SUBLEVEL) \
			       ]; then echo \
/usr/src/kernel-patches/$(architecture)/$(VERSION).$(PATCHLEVEL).$(SUBLEVEL); \
			    fi)
endif

ifeq ($(strip $(VERSIONED_ALL_PATCH_DIR)),)
VERSIONED_ALL_PATCH_DIR         = $(shell if [ -d \
/usr/src/kernel-patches/all/$(VERSION).$(PATCHLEVEL).$(SUBLEVEL) \
			       ]; then echo \
/usr/src/kernel-patches/all/$(VERSION).$(PATCHLEVEL).$(SUBLEVEL); \
			    fi)
endif

ifeq ($(strip $(PATCH_DIR)),)
PATCH_DIR  = $(shell if [ -d /usr/src/kernel-patches/$(architecture)/ ];\
                        then echo /usr/src/kernel-patches/$(architecture); \
	             fi)
endif

ifeq ($(strip $(ALL_PATCH_DIR)),)
ALL_PATCH_DIR  = $(shell if [ -d /usr/src/kernel-patches/all/ ]; \
                            then echo /usr/src/kernel-patches/all ;\
			 fi)
endif

VERSIONED_ALL_PATCH_APPLY   = $(VERSIONED_ALL_PATCH_DIR)/apply
VERSIONED_ALL_PATCH_UNPATCH = $(VERSIONED_ALL_PATCH_DIR)/unpatch

VERSIONED_DIR_PATCH_APPLY   = $(VERSIONED_PATCH_DIR)/apply
VERSIONED_DIR_PATCH_UNPATCH = $(VERSIONED_PATCH_DIR)/unpatch

ALL_PATCH_APPLY   = $(ALL_PATCH_DIR)/apply
ALL_PATCH_UNPATCH = $(ALL_PATCH_DIR)/unpatch

DIR_PATCH_APPLY   = $(PATCH_DIR)/apply
DIR_PATCH_UNPATCH = $(PATCH_DIR)/unpatch

# The destination of all .deb files
# (suggested by Rob Browning <osiris@cs.utexas.edu>)
DEB_DEST := ..
SRCTOP := $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)
INSTALL_MOD_PATH=$(SRCTOP)/$(IMAGE_TOP)
KPKG_DEST_DIR ?= $(SRCTOP)/..

# Include any site specific overrides here.
-include $(CONFLOC)

# Over ride the config file from the environment/command line
ifneq ($(strip $(KPKG_MAINTAINER)),)
maintainer=$(KPKG_MAINTAINER)
endif

ifneq ($(strip $(KPKG_EMAIL)),)
email=$(KPKG_EMAIL)
endif

# This should be a  name to feed the modules build for pgp signature,
# since we the maintainer would be different there.
ifneq ($(strip $(PGP_SIGNATURE)),)
pgp=$(PGP_SIGNATURE)
endif

ifneq ($(strip $(EXTRA_DOCS)),)
extra_docs = $(EXTRA_DOCS)
endif

ifneq ($(strip $(extra_docs)),)
HAVE_EXTRA_DOCS:=$(shell if [ -e $(extra_docs) ]; then echo YES; fi)
endif

ifneq ($(strip $(DEBIAN_REVISION_MANDATORY)),)
debian_revision_mandatory:=$(DEBIAN_REVISION_MANDATORY)
endif


ifneq ($(strip $(install_vmlinux)),)
int_install_vmlinux:=$(install_vmlinux)
endif

ifneq ($(strip $(KPKG_FOLLOW_SYMLINKS_IN_SRC)),)
int_follow_symlinks_in_src=YES
else
ifneq ($(strip $(kpkg_follow_symlinks_in_src)),)
int_follow_symlinks_in_src=YES
endif
endif





# The Debian revision
ifneq ($(strip $(DEBIAN_REVISION)),)
  HAS_CHANGELOG := $(shell \
    if test -f debian/changelog && ( test -f stamp-debian || test -f debian/official );\
    then echo YES;\
    else echo NO; fi; )
else
  HAS_CHANGELOG := $(shell if test -f debian/changelog; then echo YES;\
                          else echo NO; fi; )
endif
# If there is a changelog file, it overrides. The only exception is
# when there is no stamp-config, and there is no debian/official,
# *AND* there is a DEBIAN_REVISION, in which case the DEBIAN_REVISION
# over rides (since we are going to replace the changelog file soon
# anyway.  Else, use the commandline or env var setting. Or else
# default to 10.00.Custom, unless the human has requested that the
# revision is mandatory, in which case we raise an error

ifeq ($(strip $(HAS_CHANGELOG)),YES)
  debian := $(shell if test -f debian/changelog; then \
                     perl -nle 'print /\((\S+)\)/; exit 0' debian/changelog;\
                  fi; )
else
  ifneq ($(strip $(DEBIAN_REVISION)),)
    debian := $(DEBIAN_REVISION)
  else
    ifeq ($(strip $(debian)),)
      ifneq ($(strip $(debian_revision_mandatory)),)
        $(error A Debian revision is mandatory, but none was provided)
      else
        debian := 10.00.Custom
      endif
    endif
  endif
endif

# Hmm. The version that we have computed *MUST* match the one that is in the
# changelog.
ifeq ($(strip $(HAS_CHANGELOG)),YES)
  saved_version := $(shell if test -f debian/changelog; then \
                     perl -nle 'print /^$(INT_STEM)-source-(\S+)/; exit 0' \
                          debian/changelog;\
                  fi; )
# Warn people about version mismatches, unless they are running an
# "official" version, in which case they can shoot themselves in the
# foot if they so desire
  ifneq ($(strip $(saved_version)),)
    ifneq ($(strip $(saved_version)),$(strip $(version)))
      HAVE_VERSION_MISMATCH:=$(shell if test ! -f debian/official;then echo YES; fi; )
    endif
  endif
endif


ifneq ($(strip $(DELETE_BUILD_LINK)),)
delete_build_link := YES
else
ifeq ($(strip $(delete_build_link)),)
delete_build_link := $(shell if test -f debian/official; then echo YES;\
                          else echo NO; fi; )
endif
endif

ifneq ($(strip $(IMAGE_IN_BOOT)),)
link_in_boot := $(IMAGE_IN_BOOT)
endif

ifneq ($(strip $(LINK_IN_BOOT)),)
link_in_boot := $(LINK_IN_BOOT)
endif

ifneq ($(strip $(NO_SYMLINK)),)
no_symlink := $(NO_SYMLINK)
endif

ifneq ($(strip $(REVERSE_SYMLINK)),)
reverse_symlink := $(REVERSE_SYMLINK)
endif

ifneq ($(strip $(IMAGE_TYPE)),)
kimage = $(IMAGE_TYPE)
endif

ifneq ($(strip $(PATCH_THE_KERNEL)),)
patch_the_kernel = $(PATCH_THE_KERNEL)
endif

ifneq ($(strip $(KPKG_SELECTED_PATCHES)),)
ifeq ($(strip $(patch_the_kernel)),NO)
patch_the_kernel = NO
else
ifeq ($(strip $(patch_the_kernel)),no)
patch_the_kernel = NO
else
patch_the_kernel = YES
endif
endif
endif


ifeq ($(strip $(patch_the_kernel)),yes)
patch_the_kernel = YES
endif
ifeq ($(strip $(patch_the_kernel)),Yes)
patch_the_kernel = YES
endif
ifeq ($(strip $(patch_the_kernel)),YEs)
patch_the_kernel = YES
endif
ifeq ($(strip $(patch_the_kernel)),yEs)
patch_the_kernel = YES
endif
ifeq ($(strip $(patch_the_kernel)),yES)
patch_the_kernel = YES
endif
ifeq ($(strip $(patch_the_kernel)),yeS)
patch_the_kernel = YES
endif



ifneq ($(strip $(CONFIG_TARGET)),)
config_target := $(CONFIG_TARGET)
have_new_config_target := YES
endif

# If config_target doesn't end in 'config' then reset it to 'oldconfig'.
ifneq ($(patsubst %config,config,$(strip $(config_target))),config)
config_target := oldconfig
have_new_config_target :=
endif

ifneq ($(strip $(USE_SAVED_CONFIG)),)
use_saved_config = $(USE_SAVED_CONFIG)
endif

#ifeq ($(origin var),command line)
#$(warn You are setting an internal var from the cmdline. Use at your own risk)
#endif
#you can automated it a bit more with $(foreach) and $(if)


###
### In the following, we define these variables
### ROOT_CMD      -- set in the environment, plaing old sudo or fakeroot
### root_cmd      -- The same
### int_root_cmd  -- the argument passed to dpkg-buildpackage
###                  -r$(ROOT_CMD)
ifneq ($(strip $(ROOT_CMD)),)
 # ROOT_CMD is not supposed to have -r or -us and -uc
 int_dummy_root := $(ROOT_CMD)
 # remove -us and -uc
 ifneq ($(strip $(findstring -us, $(int_dummy_root))),)
   int_dummy_root := $(subst -us,, $(strip $(int_dummy_root)))
   int_us := -us
 endif
 ifneq ($(strip $(findstring -uc, $(int_dummy_root))),)
   int_dummy_root := $(subst -uc,, $(strip $(int_dummy_root)))
   int_uc := -uc
 endif
 ifneq ($(strip $(findstring -r, $(int_dummy_root))),)
   int_dummy_root := $(subst -r,, $(strip $(int_dummy_root)))
 endif
 # sanitize
 ROOT_CMD     :=   $(strip $(int_dummy_root))
 int_root_cmd := -r$(strip $(int_dummy_root))
else
  # well, ROOT_CMD is not set yet
  ifneq ($(strip $(root_cmd)),)
    # Try and set ROOT_CMD from root_cmd
    int_dummy_root := $(root_cmd)
    # remove -us and -uc
    ifneq ($(strip $(findstring -us, $(int_dummy_root))),)
      int_dummy_root := $(subst -us,, $(strip $(int_dummy_root)))
      int_us := -us
    endif
    ifneq ($(strip $(findstring -uc, $(int_dummy_root))),)
      int_dummy_root := $(subst -uc,, $(strip $(int_dummy_root)))
      int_uc := -uc
    endif
    # now that -us and -uc are gone, remove -r
    ifneq ($(strip $(findstring -r, $(int_dummy_root))),)
      int_dummy_root := $(subst -r,, $(strip $(int_dummy_root)))
    endif
    # Finally, sanitized
    ROOT_CMD     :=   $(strip $(int_dummy_root))
    int_root_cmd := -r$(strip $(int_dummy_root))
  endif
endif

# make sure that root_cmd and ROOT_CMD are the same
ifneq ($(strip $(ROOT_CMD)),)
  root_cmd := $(ROOT_CMD)
endif

ifneq ($(strip $(UNSIGN_SOURCE)),)
  int_us := -us
endif

ifneq ($(strip $(UNSIGN_CHANGELOG)),)
  int_uc := -uc
endif

int_am_root  := $(shell [ $$(id -u) -eq 0 ] && echo "YES" )


ifneq ($(strip $(CLEAN_SOURCE)),)
do_clean = $(CLEAN_SOURCE)
endif

ifneq ($(strip $(CONCURRENCY_LEVEL)),)
do_parallel = -j$(CONCURRENCY_LEVEL)

# Well, I wish there was something better than guessing by version number
CAN_DO_DEP_FAST=$(shell if   [ $(VERSION) -lt 2 ];    then echo '';  \
                        elif [ $(VERSION) -gt 2 ];    then echo YES; \
                        elif [ $(PATCHLEVEL) -lt 4 ]; then echo '';  \
                        else                             echo YES; \
                        fi)
ifneq ($(strip $(CAN_DO_DEP_FAST)),)
fast_dep= -j$(CONCURRENCY_LEVEL)
endif

endif

ifneq ($(strip $(SOURCE_CLEAN_HOOK)),)
source_clean_hook=$(SOURCE_CLEAN_HOOK)
endif
ifneq ($(strip $(HEADER_CLEAN_HOOK)),)
header_clean_hook=$(HEADER_CLEAN_HOOK)
endif
ifneq ($(strip $(DOC_CLEAN_HOOK)),)
doc_clean_hook=$(DOC_CLEAN_HOOK)
endif
ifneq ($(strip $(IMAGE_CLEAN_HOOK)),)
image_clean_hook=$(IMAGE_CLEAN_HOOK)
endif

#
# INITRD tools.
#
initrdcmd:=
initrddep:=

ifneq ($(strip $(INITRD)),)
  ifneq ($(strip $(INITRD_CMD)),)
    initrdcmd := $(strip $(INITRD_CMD))
  else
    ifneq ($(shell if [ $(VERSION)  -eq  2 ] && [ $(PATCHLEVEL) -eq 6 ] &&    \
                      [ $(SUBLEVEL) -lt  8 ]; then                            \
                        echo old;                                             \
                 elif [ $(VERSION)  -eq  2 ] && [ $(PATCHLEVEL) -lt 6 ]; then \
                        echo old;                                             \
                 elif [ $(VERSION)  -lt  2 ]; then                            \
                        echo old;                                             \
                 fi),)
      initrdcmd := mkinitrd
    else
      ifneq ($(shell if [ $(VERSION)  -eq  2 ] && [ $(PATCHLEVEL) -eq 6 ] &&  \
                        [ $(SUBLEVEL) -ge  8 ]; then                          \
                          echo old;                                           \
                   elif [ $(VERSION)  -eq  2 ] && [ $(PATCHLEVEL) -eq 6 ] &&  \
                        [ $(SUBLEVEL) -le 12 ]; then                          \
                          echo old;                                           \
                   fi),)
        initrdcmd := mkinitrd mkinitrd.yaird
      else
        initrdcmd := mkinitrd.yaird mkinitramfs
      endif
    endif
  endif
  ifneq (,$(findstring initrd-tools, $(initrdcmd)))
    initrddep := initrd-tools (>= 0.1.84)
  endif
  #setup initrd dependencies
  ifneq (,$(findstring yaird,$(initrdcmd)))
    ifneq (,$(strip $(initrddep)))
      initrddep := $(initrddep) | yaird (>= 0.1.11)
    else
      initrddep := yaird (>= 0.0.11-8)
    endif
  endif
  ifneq (,$(findstring mkinitramfs,$(initrdcmd)))
    ifneq (,$(strip $(initrddep)))
      initrddep := $(initrddep) | initramfs-tools (>= 0.35)
    else
      initrddep := initramfs-tools (>= 0.35)
    endif
  endif
  # By this time initrddep is not empty, so we can dispense with the emptiness test
  ifneq (,$(findstring yaird,$(initrdcmd)))
    initrddep := $(initrddep) | linux-initramfs-tools
  else
    ifneq (,$(findstring mkinitramfs,$(initrdcmd)))
      initrddep := $(initrddep) | linux-initramfs-tools
    endif
  endif
  initrddep := $(initrddep), # There is a blank here
else
  initrdcmd :=
  initrddep :=
endif

ifeq ($(strip $(CONFDIR)),)
ifeq ($(strip $(patch_the_kernel)),YES)
CONFDIR     = $(PATCH_DIR)
else
ifeq ($(strip $(patch_the_kernel)),yes)
CONFDIR     = $(PATCH_DIR)
else
$(eval $(which_debdir))
CONFDIR     = $(DEBDIR)/Config
endif
endif
endif

# The file which has local configuration
$(eval $(which_debdir))
CONFIG_FILE := $(shell if test -e .config ; then \
                           echo .config; \
                       elif test -e $(DEBCONFIG) ; then \
                           echo $(DEBCONFIG); \
                       elif test -e $(CONFDIR)/config ; then \
                           echo $(CONFDIR)/config ; \
                       elif test -e $(DEBDIR)/config ; then \
                           echo $(DEBDIR)/config ; \
                       elif test -e /boot/config-$(version) ; then \
                           echo /boot/config-$(version) ; \
                       elif test -e /boot/config-$$(uname -r) ; then \
                           echo /boot/config-$$(uname -r) ; \
                       else echo /dev/null ; \
                       fi)


# Deal with modules issues

# define MODULES_ENABLED if appropriate
ifneq ($(filter kfreebsd-gnu, $(DEB_HOST_GNU_SYSTEM)):$(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),:)
  MODULES_ENABLED := YES
endif

# accept both space separated list of modules, as well as comma
# separated ones
valid_modules:=

# See what modules we are talking about
ifeq ($(strip $(MODULES_ENABLED)),YES)
ifneq ($(strip $(KPKG_SELECTED_MODULES)),)
canonical_modules=$(subst $(comma),$(space),$(KPKG_SELECTED_MODULES))
else
canonical_modules=$(shell test -e $(MODULE_LOC) && \
                       find $(MODULE_LOC) -follow -maxdepth 1 -type d -print |\
			   grep -E -v '^$(MODULE_LOC)/$$')
endif


# Now, if we have any modules at all, they are in canonical_modules
ifneq ($(strip $(canonical_modules)),)

# modules can have the full path, or just the name of the module. We
# make all the modules ahve absolute paths by fleshing them out.
path_modules   :=$(filter     /%, $(canonical_modules))
no_path_modules:=$(filter-out /%, $(canonical_modules))
fleshed_out    :=$(foreach mod,$(no_path_modules),$(MODULE_LOC)/$(mod))

# Hmmph. recreate the canonical modules; now everything has a full
# path name.

canonical_modules:=$(path_modules) $(fleshed_out)
# test to see if the dir names are real
valid_modules = $(shell for dir in $(canonical_modules); do \
                            if [ -d $$dir ] && [ -x $$dir/debian/rules ]; then \
                               echo $$dir;                  \
                            fi;                             \
                        done)


endif
endif

ifeq ($(strip $(patch_the_kernel)),YES)

# Well then. Let us see if we want to select the patches we apply.
ifneq ($(strip $(KPKG_SELECTED_PATCHES)),)
canonical_patches=$(subst $(comma),$(space),$(KPKG_SELECTED_PATCHES))

ifneq ($(strip $(canonical_patches)),)
# test to see if the patches exist
temp_valid_patches = $(shell for name in $(canonical_patches); do                \
                            if [ -x "$(VERSIONED_DIR_PATCH_APPLY)/$$name"   ] &&   \
                               [ -x "$(VERSIONED_DIR_PATCH_UNPATCH)/$$name" ];     \
                               then echo "$(VERSIONED_DIR_PATCH_APPLY)/$$name";    \
                            elif [ -x "$(VERSIONED_ALL_PATCH_APPLY)/$$name"   ] && \
                                 [ -x "$(VERSIONED_ALL_PATCH_UNPATCH)/$$name" ];   \
                               then echo "$(VERSIONED_ALL_PATCH_APPLY)/$$name";    \
                            elif [ -x "$(DIR_PATCH_APPLY)/$$name"   ] &&           \
                                 [ -x "$(DIR_PATCH_UNPATCH)/$$name" ]; then        \
                               echo "$(DIR_PATCH_APPLY)/$$name";                   \
                            elif [ -x "$(ALL_PATCH_APPLY)/$$name"   ] &&           \
                                 [ -x "$(ALL_PATCH_UNPATCH)/$$name" ]; then        \
                               echo "$(ALL_PATCH_APPLY)/$$name";                   \
                            else                                                 \
                               echo "$$name.error";                                \
                            fi;                                                  \
                        done)

temp_patch_not_found = $(filter %.error, $(temp_valid_patches))
patch_not_found = $(subst .error,,$(temp_patch_not_found))
ifneq ($(strip $(patch_not_found)),)
$(error Could not find patch for $(patch_not_found))
endif

valid_patches = $(filter-out %.error, $(temp_valid_patches))

ifeq ($(strip $(valid_patches)),)
$(error Could not find patch scripts for $(canonical_patches))
endif



canonical_unpatches = $(shell new="";                                         \
                              for name in $(canonical_patches); do            \
                                  new="$$name $$new";                         \
                              done;                                           \
                              echo $$new;)

temp_valid_unpatches = $(shell for name in $(canonical_unpatches); do            \
                            if [ -x "$(VERSIONED_DIR_PATCH_APPLY)/$$name"   ] &&   \
                               [ -x "$(VERSIONED_DIR_PATCH_UNPATCH)/$$name" ];     \
                              then echo "$(VERSIONED_DIR_PATCH_UNPATCH)/$$name";   \
                            elif [ -x "$(VERSIONED_ALL_PATCH_APPLY)/$$name"   ] && \
                                 [ -x "$(VERSIONED_ALL_PATCH_UNPATCH)/$$name" ];   \
                              then echo "$(VERSIONED_ALL_PATCH_UNPATCH)/$$name";   \
                            elif [ -x "$(DIR_PATCH_APPLY)/$$name"   ] &&           \
                                 [ -x "$(DIR_PATCH_UNPATCH)/$$name" ]; then        \
                               echo "$(DIR_PATCH_UNPATCH)/$$name";                 \
                            elif [ -x "$(ALL_PATCH_APPLY)/$$name"   ] &&           \
                                 [ -x "$(ALL_PATCH_UNPATCH)/$$name" ]; then        \
                               echo "$(ALL_PATCH_UNPATCH)/$$name";                 \
                            else                                                 \
                               echo $$name.error;                                \
                            fi;                                                  \
                        done)
temp_unpatch_not_found = $(filter %.error, $(temp_valid_unpatches))
unpatch_not_found = $(subst .error,,$(temp_unpatch_not_found))
ifneq ($(strip $(unpatch_not_found)),)
$(error Could not find unpatch for $(unpatch_not_found))
endif

valid_unpatches = $(filter-out %.error, $(temp_valid_unpatches))

ifeq ($(strip $(valid_unpatches)),)
$(error Could not find un-patch scripts for $(canonical_unpatches))
endif


endif
else
# OK. We want to patch the kernel, but there are no patches specified.
valid_patches = $(shell if [ -n "$(VERSIONED_PATCH_DIR)" ] &&                 \
                           [ -n "$(VERSIONED_DIR_PATCH_APPLY)" ] &&           \
                           [ -d "$(VERSIONED_DIR_PATCH_APPLY)" ]; then        \
                               run-parts --test $(VERSIONED_DIR_PATCH_APPLY); \
                        fi;                                                   \
                        if [ -n "$(VERSIONED_ALL_PATCH_DIR)" ] &&             \
                           [ -n "$(VERSIONED_ALL_PATCH_APPLY)" ] &&           \
                           [ -d "$(VERSIONED_ALL_PATCH_APPLY)" ]; then        \
                               run-parts --test $(VERSIONED_ALL_PATCH_APPLY); \
                        fi;                                                   \
                        if [ -n "$(PATCH_DIR)" ] &&                           \
                           [ -n "$(DIR_PATCH_APPLY)" ] &&                     \
                           [ -d "$(DIR_PATCH_APPLY)" ]; then                  \
                              run-parts --test $(DIR_PATCH_APPLY);            \
                        fi;                                                   \
                        if [ -n "$(ALL_PATCH_DIR)" ] &&                       \
                           [ -n "$(ALL_PATCH_APPLY)" ] &&                     \
                           [ -d "$(ALL_PATCH_APPLY)"  ]; then                 \
                              run-parts --test $(ALL_PATCH_APPLY);            \
                        fi)
valid_unpatches = $(shell ( if [ -n "$(VERSIONED_PATCH_DIR)"       ]  &&          \
                               [ -n "$(VERSIONED_DIR_PATCH_UNPATCH)" ] &&         \
                               [ -d "$(VERSIONED_DIR_PATCH_UNPATCH)" ]; then      \
                                 run-parts --test $(VERSIONED_DIR_PATCH_UNPATCH); \
                            fi;                                                   \
                            if [ -n "$(VERSIONED_ALL_PATCH_DIR)"    ]  &&         \
                               [ -n "$(VERSIONED_ALL_PATCH_UNPATCH)" ] &&         \
                               [ -d "$(VERSIONED_ALL_PATCH_UNPATCH)"  ]; then     \
                                 run-parts --test $(VERSIONED_ALL_PATCH_UNPATCH); \
                            fi;                                                   \
                            if [ -n "$(PATCH_DIR)"       ]  &&                    \
                               [ -n "$(DIR_PATCH_UNPATCH)" ] &&                   \
                               [ -d "$(DIR_PATCH_UNPATCH)" ]; then                \
                                 run-parts --test $(DIR_PATCH_UNPATCH);           \
                            fi;                                                   \
                            if [ -n "$(ALL_PATCH_DIR)"    ]  &&                   \
                               [ -n "$(ALL_PATCH_UNPATCH)" ] &&                   \
                               [ -d "$(ALL_PATCH_UNPATCH)"  ]; then               \
                                run-parts --test $(ALL_PATCH_UNPATCH);            \
                            fi) | tac)
endif
endif

old_applied_patches=$(shell if [ -f applied_patches ]; then                   \
                               cat applied_patches;                           \
                            else                                              \
                               echo '';                                       \
                            fi )

ifeq ($(strip $(valid_unpatches)),)
ifneq ($(strip $(old_applied_patches)),)
old_unpatches=$(shell new="";                                          \
                      for name in $(notdir $(old_applied_patches)); do \
                          new="$$name $$new";                          \
                      done;                                            \
                      echo $$new;)
temp_old_unpatches = $(shell for name in $(old_unpatches); do         \
                            if [ -x "$(VERSIONED_DIR_PATCH_UNPATCH)/$$name" ];  \
                              then echo "$(VERSIONED_DIR_PATCH_UNPATCH)/$$name";\
                            elif [ -x "$(VERSIONED_ALL_PATCH_UNPATCH)/$$name" ];\
                              then echo "$(VERSIONED_ALL_PATCH_UNPATCH)/$$name";\
                            elif [ -x "$(DIR_PATCH_UNPATCH)/$$name" ]; then     \
                               echo "$(DIR_PATCH_UNPATCH)/$$name";              \
                            elif [ -x "$(ALL_PATCH_UNPATCH)/$$name" ]; then     \
                               echo "$(ALL_PATCH_UNPATCH)/$$name";              \
                            else                                              \
                               echo "$$name.error";                             \
                            fi;                                               \
                        done)
temp_old_unpatch_not_found = $(filter %.error, $(temp_old_unpatches))
old_unpatch_not_found = $(subst .error,,$(temp_unpatch_not_found))
valid_unpatches = $(filter-out %.error, $(temp_old_unpatches))
endif
endif

# See if the version numbers are valid
$(eval $(which_debdir))
HAVE_VALID_PACKAGE_VERSION := $(shell                           \
      if test -x $(DEBDIR)/scripts/kpkg-vercheck; then          \
	$(DEBDIR)/scripts/kpkg-vercheck $(debian) ;             \
      else                                                      \
        echo "Could not find $(DEBDIR)/scripts/kpkg-vercheck" ; \
      fi )

TAR_COMPRESSION := $(shell                                             \
      if tar --help | grep -- \-\-bzip2 >/dev/null; then echo --bzip2; \
      else                                               echo --gzip;  \
      fi )
TAR_SUFFIX := $(shell                                                  \
      if tar --help | grep -- \-\-bzip2 >/dev/null; then echo bz2;     \
      else                                               echo gz;      \
      fi )

STOP_FOR_BIN86 = NO
CONTROL=$(LIBLOC)/Control
ifeq ($(strip $(architecture)),i386)
NEED_BIN86 := $(shell if dpkg --compare-versions                   \
                  $(VERSION).$(PATCHLEVEL) lt 2.4 >/dev/null 2>&1; \
                  then echo YES; fi)
ifeq ($(strip $(NEED_BIN86)),YES)
CONTROL=$(LIBLOC)/Control.bin86
HAVE_BIN86 := $(shell if test -x /usr/bin/as86; then echo YES; else echo NO; fi )
ifeq ($(strip $(HAVE_BIN86)),NO)
STOP_FOR_BIN86 = YES
endif
endif
endif



ifeq (,$(strip $(kimagedest)))
$(error Error. I do not know where the kernel image goes to [kimagedest undefined] \
 The usual case for this is that I could not determine which arch or subarch       \
 this machine belongs to. Please specify a subarch, and try again.)
endif
ifeq (,$(strip $(kimagesrc)))
$(error Error. I do not know where the kernel image goes to [kimagesrc undefined] \
 The usual case for this is that I could not determine which arch or subarch      \
 this machine belongs to. Please specify a subarch, and try again.)
endif
