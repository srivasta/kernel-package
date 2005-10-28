######################### -*- Mode: Makefile-Gmake -*- ########################
## local.mk<ruleset> --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:37:46 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Fri Oct 28 00:37:59 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: d047cfca-c918-4f47-b6e2-8c7df9778b26
## 
###############################################################################



ifeq ($(strip $(IN_KERNEL_DIR)),)
# Hah! Not in kernel directory!!
build configure clean binary kernel_source kernel-source kernel-headers\
stamp-source kernel_headers stamp-headers kernel_image stamp-image \
kernel-image kernel-doc kernel_doc kernel-manual kernel_manual stamp-doc stamp-manual \
buildpackage kernel-image-deb debian:
	@echo "You should invoke this command from the top level directory of"
	@echo "a linux kernel source directory tree, and as far as I can tell,"
	@echo "the current directory:"
	@echo "	$(SRCTOP)"
	@echo "is not a top level linux kernel source directory. "
	@echo ""
	@echo "	(If I am wrong then kernel-packages and the linux kernel"
	@echo "	 are so out sync that you'd better get the latest versions"
	@echo "	 of the kernel-package package and the Linux sources)"
	@echo ""
	@echo "Please change directory to wherever linux kernel sources"
	@echo "reside and try again."
else
ifneq ($(strip $(HAVE_VALID_PACKAGE_VERSION)),YES)
# Hah! Bogus version number
build configure clean binary kernel_source kernel-source kernel-headers\
stamp-source kernel_headers stamp-headers kernel_image stamp-image \
kernel-image kernel-doc kernel_doc kernel-manual kernel_manual stamp-doc stamp-manual \
buildpackage kernel-image-deb debian:
	@echo "Problems ecountered with the version number $(debian)."
	@echo "$(HAVE_VALID_PACKAGE_VERSION)"
	@echo ""
	@echo "Please re-read the README file and try again."
else
ifeq ($(strip $(STOP_FOR__BIN86)),YES)
# Hah! we need bin 86, but it aint here
build configure clean binary kernel_source kernel-source kernel-headers\
stamp-source kernel_headers stamp-headers kernel_image stamp-image \
kernel-image kernel-doc kernel_doc kernel-manual kernel_manual stamp-doc stamp-manual \
buildpackage kernel-image-deb debian:
	@echo "You Need to install the package bin86 before you can "
	@echo "compile the kernel on this machine"
	@echo ""
	@echo "Please install bin86 and try again."
else
all build: debian configure stamp-build

# stamp-debian and stamp-configure used to be a single target. Now
# they are split - the reason is that arch-indep packages need to be
# built before arch-dep packages, and make-kpkg tries to do 'make
# config' for both cases.  This used to work because the .config file
# resided with kernel-source, but now that it is in kernel-patch, it
# breaks down.  I think the cleanest way out of this is to only deal
# with config files when necessary, and thus the split. Herbert Xu
debian: stamp-debian

stamp-debian:
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	# work around idiocy in recent kernel versions
	test ! -e scripts/package/builddeb || \
            mv -f scripts/package/builddeb scripts/package/builddeb.dist
	test ! -e scripts/package/Makefile || \
            (mv -f scripts/package/Makefile scripts/package/Makefile.dist && \
               (echo "# Dummy file "; echo "help:") >  scripts/package/Makefile)
	@test -f $(LIBLOC)/rules || \
            echo Error: Could not find $(LIBLOC)/rules
	-test ! -f stamp-debian && test ! -f debian/official && \
	      rm -rf ./debian && mkdir ./debian
ifeq ($(strip $(patch_the_kernel)),YES)
	-test -f applied_patches && rm -f applied_patches
ifneq ($(strip $(valid_patches)),)
	-for patch in $(valid_patches) ; do            \
          if test -x  $$patch; then                    \
              if $$patch; then                         \
                  echo "Patch $$patch processed fine"; \
		  echo "$(notdir $$patch)" >> applied_patches;   \
              else                                     \
                   echo "Patch $(notdir $$patch)  failed.";      \
                   echo "Hit return to Continue";      \
		   read ans;                           \
              fi;                                      \
	  fi;                                          \
        done
	echo done >  stamp-patch
endif
endif
	-test ! -f stamp-debian && \
               ( test ! -f debian/official || test ! -f debian/control) && \
	   sed -e 's/=V/$(version)/g'         -e 's/=D/$(debian)/g'        \
	       -e 's/=A/$(DEB_HOST_ARCH)/g'   -e 's/=SA/$(INT_SUBARCH)/g'  \
                -e 's/=L/$(int_loaderdep) /g' -e 's/=I/$(initrddep)/g'     \
                -e 's/=CV/$(VERSION).$(PATCHLEVEL)/g'                      \
                -e 's/=M/$(maintainer) <$(email)>/g'                       \
                -e 's/=ST/$(INT_STEM)/g'      -e 's/=B/$(KERNEL_ARCH)/g' \
		         $(CONTROL)> debian/control
	-test ! -f stamp-debian && test ! -f debian/official &&               \
	   sed -e 's/=V/$(version)/g' -e 's/=D/$(debian)/g'                   \
	    -e 's/=A/$(DEB_HOST_ARCH)/g' -e 's/=M/$(maintainer) <$(email)>/g' \
            -e 's/=ST/$(INT_STEM)/g'     -e 's/=B/$(KERNEL_ARCH)/g'           \
		$(LIBLOC)/changelog > debian/changelog
	-test ! -f debian/rules &&                                       \
	   install -p -m 755 $(LIBLOC)/rules debian/rules
	-test ! -f stamp-debian && test ! -f debian/official &&              \
	for file in $(DEBIAN_FILES); do cp -f  $(LIBLOC)/$$file ./debian/; done
	for dir  in $(DEBIAN_DIRS);  do cp -af $(LIBLOC)/$$dir  ./debian/; done
	echo done >  $@

.config: stamp-debian
ifneq ($(strip $(use_saved_config)),NO)
	test -f .config || test ! -f .config.save || \
		            cp -pf .config.save .config
endif
	test -f .config || test ! -f $(CONFIG_FILE) || \
		            cp -pf $(CONFIG_FILE) .config
	$(eval $(which_debdir))
	test -f .config || test ! -f $(DEBDIR)/config || \
		            cp -pf $(DEBDIR)/config  .config
ifeq ($(strip $(have_new_config_target)),)
	test -f .config || (echo "*** Need a config file .config" && false)
endif
# if $(have_new_config_target) is set, then we need not have a .config
# file at this point


conf.vars: Makefile .config
	@rm -f .mak
	@touch .mak
	@echo Please ignore the warning about overriding and ignoring targets above.
	@echo These are harmless. They are only invoked in a part of the process
	@echo that tries to snarf variable values for the conf.vars file.
	@echo "VERSION          = $(VERSION)"       >> .mak
	@echo "PATCHLEVEL       = $(PATCHLEVEL)"    >> .mak
	@echo "SUBLEVEL 	= $(SUBLEVEL)"      >> .mak
	@echo "EXTRAVERSION     = $(EXTRAVERSION)"  >> .mak
ifneq ($(strip $(iatv)),)
	@echo "APPEND_TO_VERSION = $(iatv)"         >> .mak
endif
ifeq ($(strip $(patch_the_kernel)),YES)
	@echo "KPKG_SELECTED_PATCHES = $(KPKG_SELECTED_PATCHES)" >> .mak
endif
ifeq ($(strip $(MODULES_ENABLED)),YES)
	@echo "KPKG_SELECTED_MODULES = $(KPKG_SELECTED_MODULES)" >> .mak
endif
	@echo "Debian Revision  = $(debian)"        >> .mak
	@echo "KPKG_ARCH        = $(KPKG_ARCH)"        >> .mak
# Fetch the rest of the information from the kernel's Makefile
	$(eval $(which_debdir))
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
	@$(MAKE) --no-print-directory -sf $(DEBDIR)/ruleset/kernel_version.mk  \
          ARCH=$(KERNEL_ARCH) $(CROSS_ARG) debian_conf_var              >> .mak
endif
	@echo "do_parallel      = $(do_parallel)"   >> .mak
	@echo "fast_dep         = $(fast_dep)"      >> .mak
#	@sed -e 's%$(TOPDIR)%$$(TOPDIR)%g' .mak     > conf.vars
# Use the kernel's Makefile to calculate the TOPDIR.
# TOPDIR is obsolete in 2.6 kernels, so the kernel_version.mk
# will get us the right answer
	@sed -e 's%$(shell $(MAKE) --no-print-directory -sf $(DEBDIR)/ruleset/kernel_version.mk debian_TOPDIR)%$$(TOPDIR)%g' .mak     > conf.vars
	@rm -f .mak


dummy_do_dep:
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
	+$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) \
                                 ARCH=$(KERNEL_ARCH) $(fast_dep) dep
else
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
	$(PMAKE) -C $(architecture)/compile/GENERIC depend
  endif
endif

stamp-kernel-configure: stamp-debian .config
ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
	mkdir -p bin
	ln -sf `which gcc-3.4` bin/cc
	cd $(architecture)/conf && freebsd-config GENERIC
endif
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) \
                                 ARCH=$(KERNEL_ARCH) $(config_target)
ifeq ($(shell if [ $(VERSION) -ge 2 ] && [ $(PATCHLEVEL) -ge 5 ]; then \
                  echo new;fi),)
	+$(MAKE) -f ./debian/rules dummy_do_dep
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) \
                                 ARCH=$(KERNEL_ARCH) clean
else
ifeq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) \
                                ARCH=$(KERNEL_ARCH) prepare
endif
endif
endif
	echo done >  $@

configure: debian .config stamp-configure
stamp-configure: stamp-debian .config conf.vars stamp-kernel-configure
	echo done >  $@



stamp-build: stamp-debian stamp-configure
# Builds the binary package.
# debian.config contains the current idea of what the image should
# have.
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
ifneq ($(strip $(UTS_RELEASE_VERSION)), $(strip $(version)))
	if [ -f include/linux/version.h ]; then                                          \
             uts_ver=$$(grep 'define UTS_RELEASE' include/linux/version.h |                \
                perl -nle  'm/^\s*\#define\s+UTS_RELEASE\s+("?)(\S+)\1/g && print $$2;'); \
	    if [ "X$$uts_ver" != "X$(strip $(UTS_RELEASE_VERSION))" ]; then              \
                echo "The UTS Release version in include/linux/version.h";                \
	        echo "     \"$$uts_ver\" ";                                               \
                echo "does not match current version " ;                                  \
                echo "     \"$(strip $(version))\" " ;                                    \
                echo "Reconfiguring." ;                                                   \
                touch Makefile;                                                           \
             fi;                                                                          \
	fi
endif
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
	$(MAKE) $(do_parallel) $(EXTRAV_ARG) $(FLAV_ARG) ARCH=$(KERNEL_ARCH) \
	                    $(CROSS_ARG) $(target)
  ifneq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	$(MAKE) $(do_parallel) $(EXTRAV_ARG) $(FLAV_ARG) ARCH=$(KERNEL_ARCH) \
	                    $(CROSS_ARG) modules
  endif
else
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
	$(PMAKE) -C $(architecture)/compile/GENERIC
  endif
endif
	COLUMNS=150 dpkg -l 'gcc*' perl dpkg 'libc6*' binutils ldso make dpkg-dev |\
         awk '$$1 ~ /[hi]i/ { printf("%s-%s\n", $$2, $$3) }'   > debian/buildinfo
	@echo this was built on a machine with the kernel: >> debian/buildinfo
	uname -a >> debian/buildinfo
	echo using the compiler: >> debian/buildinfo
	grep LINUX_COMPILER include/linux/compile.h | \
           sed -e 's/.*LINUX_COMPILER "//' -e 's/"$$//' >> debian/buildinfo
ifneq ($(strip $(shell test -f version.Debian && cat version.Debian)),)
	echo kernel source package used: >> debian/buildinfo
	COLUMNS=150 dpkg -l kernel-source-$(shell test -f version.Debian &&               \
                                              cat version.Debian | sed -e 's/-.*$$//') |  \
	 awk '$$1 ~ /[hi]i/ { printf("%s-%s\n", $$2, $$3) }' >> debian/buildinfo
endif
	echo applied kernel patches: >> debian/buildinfo
ifneq ($(strip $(valid_patches)),)
	COLUMNS=150 dpkg -l $(shell echo $(valid_patches) | tr ' ' '\n' |                 \
                              sed -ne 's/^.*\/\(.*\)/kernel-patch-\1/p') |                \
	      awk '$$1 ~ /[hi]i/  { printf("%s-%s\n", $$2, $$3) }' >> debian/buildinfo
endif
	echo done >  $@


# Perhaps a list of patches should be dumped to a file on patching? so we
# only unpatch what we have applied? That would be changed, though saner,
# behaviour
unpatch_now:
ifneq ($(strip $(valid_unpatches)),)
	-for patch in $(valid_unpatches) ; do              \
          if test -x  $$patch; then                        \
              if $$patch; then                             \
                  echo "Removed Patch $$patch ";           \
              else                                         \
                   echo "Patch $$patch  failed.";          \
                   echo "Hit return to Continue";          \
		   read ans;                               \
              fi;                                          \
	  fi;                                              \
        done
	rm -f stamp-patch
endif

real_stamp_clean:
	@echo running clean
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
	test ! -f .config || cp -pf .config config.precious
	-test -f Makefile && \
            $(MAKE) $(FLAV_ARG) $(EXTRAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) distclean
	test ! -f config.precious || mv -f config.precious .config
else
	rm -f .config
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
	rm -rf bin
	if test -e $(architecture)/compile/GENERIC ; then     \
	  $(PMAKE) -C $(architecture)/compile/GENERIC clean ; \
	fi
  endif
endif
	$(eval $(deb_rule))
ifeq ($(strip $(patch_the_kernel)),YES)
	$(run_command) unpatch_now
endif
ifeq ($(strip $(NO_UNPATCH_BY_DEFAULT)),)
	test ! -f stamp-patch || $(run_command) unpatch_now
endif
	-test -f stamp-building || test -f debian/official || rm -rf debian
	# work around idiocy in recent kernel versions
	test ! -e scripts/package/builddeb.dist || \
            mv -f scripts/package/builddeb.dist scripts/package/builddeb
	test ! -e scripts/package/Makefile.dist || \
            mv -f scripts/package/Makefile.dist scripts/package/Makefile
	rm -f $(FILES_TO_CLEAN) $(STAMPS_TO_CLEAN)
	rm -rf $(DIRS_TO_CLEAN)


clean:
ifeq ($(strip $(int_am_root)),)
	$(eval $(deb_rule))
ifeq ($(strip $(ROOT_CMD)),)
	@echo "You may need root privileges - some parts may fail"
endif
	$(ROOT_CMD) $(run_command) real_stamp_clean
else
	$(run_command) real_stamp_clean
endif



buildpackage: clean stamp-buildpackage
stamp-buildpackage: stamp-configure
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	echo 'Building Package' > stamp-building
	dpkg-buildpackage -nc $(strip $(int_root_cmd)) $(strip $(int_us)) $(strip $(int_uc))  \
             -m"$(maintainer) <$(email)>" -k"$(pgp)"
	rm -f stamp-building
	echo done >  $@


binary:       binary-indep binary-arch
binary-indep: kernel_source kernel_doc kernel_manual
binary-arch:  kernel_image  kernel_headers


kernel-source kernel_source: stamp-source
stamp-source: stamp-debian
	$(eval $(deb_rule))
ifeq ($(strip $(int_am_root)),)
ifeq ($(strip $(ROOT_CMD)),)
	@echo need root privileges; exit 1
else
	$(ROOT_CMD) $(run_command) real_stamp_source
endif
else
	$(run_command) real_stamp_source
endif

real_stamp_source: stamp-debian
ifneq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
	echo done >  stamp-source
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	rm -rf $(SOURCE_TOP)
	$(make_directory) $(SOURCE_TOP)/DEBIAN
	$(make_directory) $(SOURCE_SRC)
	$(make_directory) $(SOURCE_DOC)
	$(eval $(which_debdir))
	sed -e 's/=P/$(package)/g' -e 's/=V/$(version)/g'                            \
	    $(DEBDIR)/pkg/source/postinst >            $(SOURCE_TOP)/DEBIAN/postinst
	chmod 755                                      $(SOURCE_TOP)/DEBIAN/postinst
	$(install_file) README                         $(SOURCE_DOC)/README
	$(install_file) debian/changelog               $(SOURCE_DOC)/changelog.Debian
	$(install_file) $(DEBDIR)/docs/README          $(SOURCE_DOC)/debian.README
	$(install_file) $(DEBDIR)/docs/README.grub     $(SOURCE_DOC)/
	$(install_file) $(DEBDIR)/docs/README.tecra    $(SOURCE_DOC)/
	$(install_file) $(DEBDIR)/docs/README.modules  $(SOURCE_DOC)/
	$(install_file) $(DEBDIR)/docs/Flavours        $(SOURCE_DOC)/
	$(install_file) $(DEBDIR)/docs/Rationale       $(SOURCE_DOC)/
	$(install_file) $(DEBDIR)/examples/sample.module.control                   \
                                                       $(SOURCE_DOC)/
	gzip -9qfr                                     $(SOURCE_DOC)/
	$(install_file) $(DEBDIR)/pkg/source/copyright $(SOURCE_DOC)/copyright
	echo "This was produced by kernel-package version $(kpkg_version)." >      \
	                                               $(SOURCE_DOC)/Buildinfo
ifneq ($(strip $(int_follow_symlinks_in_src)),)
	-tar cfh - $$(echo * | sed -e 's/ debian//g' -e 's/\.deb//g' ) |           \
	(cd $(SOURCE_SRC); umask 000; tar xpsf -)
	(cd $(SOURCE_SRC)/include; rm -rf asm ; )
else
	-tar cf - $$(echo * | sed -e 's/ debian//g' -e 's/\.deb//g' ) |            \
	(cd $(SOURCE_SRC); umask 000; tar xspf -)
	(cd $(SOURCE_SRC)/include; rm -f asm ; )
endif
	$(install_file) debian/changelog      $(SOURCE_SRC)/Debian.src.changelog
	(cd $(SOURCE_SRC);                                                          \
            $(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) distclean)
	(cd $(SOURCE_SRC);         rm -f stamp-building $(STAMPS_TO_CLEAN))
	(cd $(SOURCE_SRC);                                                          \
         [ ! -d scripts/cramfs ]   || make -C scripts/cramfs distclean ; )
	if test -f debian/official && test -f debian/README.Debian ; then           \
           $(install_file) debian/README.Debian $(SOURCE_SRC)/README.Debian ;       \
           $(install_file) debian/README.Debian $(SOURCE_DOC)/README.Debian ;       \
	   gzip -9qf $(SOURCE_DOC)/README.Debian;                                   \
	else                                                                        \
	    sed -e 's/=V/$(version)/g' -e 's/=A/$(DEB_HOST_ARCH)/g'                 \
             -e 's/=ST/$(INT_STEM)/g'  -e 's/=B/$(KERNEL_ARCH)/g'                   \
                 $(DEBDIR)/pkg/source/README >  $(SOURCE_SRC)/README.Debian ;       \
	fi
	if test -f README.Debian ; then                                             \
           $(install_file) README.Debian        $(SOURCE_DOC)/README.Debian.1st;    \
	   gzip -9qf                            $(SOURCE_DOC)/README.Debian.1st;    \
	fi
ifneq ($(strip $(source_clean_hook)),)
	(cd $(SOURCE_SRC); test -x $(source_clean_hook) && $(source_clean_hook))
endif
	chmod -R og=rX                               $(SOURCE_TOP)
	chown -R root:root                           $(SOURCE_TOP)
	(cd $(SOURCE_TOP)/usr/src/ &&                                            \
           tar $(TAR_COMPRESSION) -cf $(package).tar.$(TAR_SUFFIX) $(package) && \
             rm -rf $(package);)
	dpkg-gencontrol -isp -p$(package)          -P$(SOURCE_TOP)/
	chmod -R og=rX                               $(SOURCE_TOP)
	chown -R root:root                           $(SOURCE_TOP)
	dpkg --build                                 $(SOURCE_TOP) $(DEB_DEST)
	rm -f -r                                     $(SOURCE_TOP)
	echo done >  stamp-source
endif

libc-kheaders libc_kheaders: 
	@echo This target is now obsolete.


kernel-headers kernel_headers: stamp-headers
stamp-headers: configure
	$(eval $(deb_rule))
ifeq ($(strip $(int_am_root)),)
ifeq ($(strip $(ROOT_CMD)),)
	@echo need root privileges; exit 1
else
	$(ROOT_CMD) $(run_command) real_stamp_headers
endif
else
	$(run_command) real_stamp_headers
endif

ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
  config = .config
else
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
    config = $(architecture)/conf/GENERIC
  endif
endif


real_stamp_headers: stamp-configure
ifneq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
	echo done >  stamp-headers
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
ifneq ($(strip $(UTS_RELEASE_VERSION)),$(strip $(version)))
	@echo "The UTS Release version in include/linux/version.h $(UTS_RELEASE_VERSION) does not match current version $(version), reconfiguring"
	touch Makefile
endif
	rm -rf $(HEADER_TOP)
	$(make_directory) $(HEADER_TOP)/DEBIAN
	$(make_directory) $(HEADER_SRC)
	$(make_directory) $(HEADER_DOC)
	$(make_directory) $(HEADER_SRC)/arch/$(KERNEL_ARCH)
	$(make_directory) $(HEADER_SRC)/arch/$(KERNEL_ARCH)/kernel/
	$(eval $(which_debdir))
	sed -e 's/=P/$(h_package)/g' -e 's/=V/$(version)/g' \
		$(DEBDIR)/pkg/headers/postinst >        $(HEADER_TOP)/DEBIAN/postinst
	chmod 755                                       $(HEADER_TOP)/DEBIAN/postinst
	$(install_file) debian/changelog                $(HEADER_DOC)/changelog.Debian
	$(install_file) $(DEBDIR)/pkg/headers/README    $(HEADER_DOC)/debian.README
	$(install_file) $(config)  	                $(HEADER_DOC)/config-$(version)
	$(install_file) conf.vars  	                $(HEADER_DOC)/conf.vars
	$(install_file) CREDITS                         $(HEADER_DOC)/
	$(install_file) MAINTAINERS                     $(HEADER_DOC)/
	$(install_file) REPORTING-BUGS                  $(HEADER_DOC)/
	$(install_file) README                          $(HEADER_DOC)/
	if test -f debian/official && test -f           debian/README.Debian ; then   \
           $(install_file) debian/README.Debian         $(HEADER_DOC)/README.Debian;  \
           $(install_file) README.Debian                $(HEADER_DOC)/README.Debian;  \
	fi
	if test -f README.Debian ; then                                                 \
           $(install_file) README.Debian                $(HEADER_DOC)/README.Debian.1st;\
	fi
	gzip -9qfr                                      $(HEADER_DOC)/
	echo "This was produced by kernel-package version: $(kpkg_version)." >         \
	                                                   $(HEADER_DOC)/Buildinfo
	chmod 0644                                         $(HEADER_DOC)/Buildinfo
	$(install_file) $(DEBDIR)/pkg/headers/copyright    $(HEADER_DOC)/copyright
	$(install_file) Makefile                           $(HEADER_SRC)
	test ! -e Rules.make || $(install_file) Rules.make $(HEADER_SRC)
	test ! -e arch/$(KERNEL_ARCH)/Makefile ||                              \
                                $(install_file) arch/$(KERNEL_ARCH)/Makefile   \
                                                     $(HEADER_SRC)/arch/$(KERNEL_ARCH)
	test ! -e Rules.make     || $(install_file) Rules.make     $(HEADER_SRC)
	test ! -e Module.symvers || $(install_file) Module.symvers $(HEADER_SRC)
ifneq ($(strip $(int_follow_symlinks_in_src)),)
	-tar cfh - include       |   (cd $(HEADER_SRC); umask 000; tar xsf -)
	-tar cfh - scripts       |   (cd $(HEADER_SRC); umask 000; tar xsf -)
	(cd $(HEADER_SRC)/include;   rm -rf asm; ln -s asm-$(KERNEL_ARCH) asm)
	find . -path './scripts/*'   -prune -o -path './Documentation/*' -prune -o  \
               -path './debian/*'    -prune -o -type f                              \
               \( -name Makefile -o  -name 'Kconfig*' \) -print  |                  \
                  cpio -pdL --preserve-modification-time $(HEADER_SRC);
else
	-tar cf - include |        (cd $(HEADER_SRC); umask 000; tar xsf -)
	-tar cf - scripts |        (cd $(HEADER_SRC); umask 000; tar xsf -)
	# Undo the move away of the scripts dir Makefile
	test ! -f $(HEADER_SRC)/scripts/package/Makefile.dist ||                  \
           mv  -f $(HEADER_SRC)/scripts/package/Makefile.dist                     \
                  $(HEADER_SRC)/scripts/package/Makefile
	test ! -f $(HEADER_SRC)/scripts/package/builddeb.dist ||                  \
           mv  -f $(HEADER_SRC)/scripts/package/builddeb.dist                     \
                  $(HEADER_SRC)/scripts/package/builddeb
	(cd       $(HEADER_SRC)/include; rm -f asm; ln -s asm-$(KERNEL_ARCH) asm)
	find . -path './scripts/*' -prune -o -path './Documentation/*' -prune -o  \
               -path './debian/*'  -prune -o -type f                              \
               \( -name Makefile -o -name 'Kconfig*' \) -print |                  \
                  cpio -pd --preserve-modification-time $(HEADER_SRC);
endif
	test ! -e arch/$(KERNEL_ARCH)/kernel/asm-offsets.s ||                     \
           $(install_file)               arch/$(KERNEL_ARCH)/kernel/asm-offsets.s \
                           $(HEADER_SRC)/arch/$(KERNEL_ARCH)/kernel/asm-offsets.s
	$(install_file) .config  	        $(HEADER_SRC)/.config
	echo $(debian)                    > $(HEADER_SRC)/$(INT_STEM)-headers.revision
ifneq ($(strip $(header_clean_hook)),)
	(cd $(HEADER_SRC); test -x $(header_clean_hook) && $(header_clean_hook))
endif
	dpkg-gencontrol -isp -DArchitecture=$(DEB_HOST_ARCH) -p$(h_package) \
                                          -P$(HEADER_TOP)/
	chown -R root:root                  $(HEADER_TOP)
	chmod -R og=rX                      $(HEADER_TOP)
	dpkg --build                        $(HEADER_TOP) $(DEB_DEST)
	rm -rf                              $(HEADER_TOP)
	echo done >  stamp-headers
endif

kernel-manual kernel_manual: stamp-manual-prep stamp-manual
stamp-manual: stamp-debian stamp-manual-prep
	$(eval $(deb_rule))
ifeq ($(strip $(int_am_root)),)
ifeq ($(strip $(ROOT_CMD)),)
	@echo need root privileges; exit 1
else
	$(ROOT_CMD) $(run_command) real_stamp_manual
endif
else
	$(run_command) real_stamp_manual
endif

stamp-manual-prep: stamp-debian
	$(eval $(deb_rule))
ifeq ($(strip $(int_am_root)),)
ifeq ($(strip $(ROOT_CMD)),)
	@echo need root privileges; exit 1
else
	$(ROOT_CMD) $(run_command) real_stamp_manual_prep
endif
else
	$(run_command) real_stamp_manual_prep
endif

real_stamp_manual_prep: stamp-debian
ifneq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
	echo done >  stamp-manual-prep
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	rm -rf            $(MAN_TOP)
	$(make_directory) $(MAN_TOP)/DEBIAN
	$(make_directory) $(MAN_DOC)
	$(make_directory) $(MAN_MAN)
	$(install_file)   debian/changelog        $(MAN_DOC)/changelog.Debian
	echo done >  stamp-manual-prep
endif

real_stamp_manual: stamp-debian stamp-manual-prep stamp-doc
ifneq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
	echo done >  stamp-manual
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	-gunzip -qfr $(MAN_MAN)
	find $(MAN_MAN) -type f -size 0 -exec rm {} \;
	-gzip -9qfr $(MAN_MAN)
	-gzip -9qfr $(MAN_DOC)
	$(install_file) $(DEBDIR)/pkg/doc/copyright $(MAN_DOC)/copyright
	dpkg-gencontrol -isp -p$(m_package)       -P$(MAN_TOP)/
	chmod -R og=rX                              $(MAN_TOP)
	chown -R root:root                          $(MAN_TOP)
	dpkg --build                                $(MAN_TOP) $(DEB_DEST)
	rm -rf                                      $(MAN_TOP)
	echo done >  stamp-manual
endif

kernel-doc kernel_doc: stamp-doc
stamp-doc: stamp-debian stamp-manual-prep
	$(eval $(deb_rule))
ifeq ($(strip $(int_am_root)),)
ifeq ($(strip $(ROOT_CMD)),)
	@echo need root privileges; exit 1
else
	$(ROOT_CMD) $(run_command) real_stamp_doc
endif
else
	$(run_command) real_stamp_doc
endif

real_stamp_doc: stamp-debian
ifneq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
	echo done >  stamp-doc
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	$(eval $(which_debdir))
	rm -rf            $(DOC_TOP)
	$(make_directory) $(DOC_TOP)/DEBIAN
	$(make_directory) $(DOC_DOC)
	$(make_directory) $(DOC_MAN)
	$(install_file) debian/changelog          $(DOC_DOC)/changelog.Debian
	$(install_file) $(DEBDIR)/pkg/doc/README  $(DOC_DOC)/README.Debian
	echo "This was produced by kernel-package version $(kpkg_version)." > \
	           $(DOC_DOC)/Buildinfo
	chmod 0644 $(DOC_DOC)/Buildinfo
	if test -f debian/official && test -f debian/README.Debian ; then \
           $(install_file) debian/README.Debian $(DOC_DOC)/README.Debian;\
	fi
	if test -f README.Debian ; then \
           $(install_file) README.Debian $(DOC_DOC)/README.Debian.1st;\
	fi
ifneq ($(strip $(shell if [ -x /usr/bin/db2html ]; then echo YSE; fi)),)
	$(MAKE)  mandocs htmldocs
endif
	-tar cf - Documentation | (cd $(DOC_DOC); umask 000; tar xsf -)
	test ! -d $(DOC_DOC)/Documentation/DocBook ||                            \
	   rm -f   $(DOC_DOC)/Documentation/DocBook/Makefile                     \
	           $(DOC_DOC)/Documentation/DocBook/*.sgml                       \
	           $(DOC_DOC)/Documentation/DocBook/*.tmpl                       \
	           $(DOC_DOC)/Documentation/DocBook/.*.sgml.cmd
	test ! -d $(DOC_DOC)/Documentation/DocBook ||                            \
	   find $(DOC_DOC)/Documentation/DocBook -name "*.9" -exec mv {}         \
	        $(MAN_MAN) \;
	test ! -d $(DOC_DOC)/Documentation/DocBook ||                            \
	   find $(DOC_DOC)/Documentation/DocBook -name "*.9.gz" -exec mv {}      \
	        $(MAN_MAN) \;
	test ! -d $(DOC_DOC)/Documentation/DocBook/man ||                       \
	   rm -rf $(DOC_DOC)/Documentation/DocBook/man
	test ! -d $(DOC_DOC)/Documentation/DocBook ||                           \
	   mv $(DOC_DOC)/Documentation/DocBook $(DOC_DOC)/html
ifneq ($(shell if [ $(VERSION) -ge 2 ] && [ $(PATCHLEVEL) -ge 5 ]; then \
	                  echo new;fi),)
		find -name Kconfig -print0 | xargs -0r cat | \
		     (umask 000 ; cat > $(DOC_DOC)/Kconfig.collected)
# removing if empty should be faster than running find twice
	if ! test -s $(DOC_DOC)/Kconfig.collected ; then \
	    rm -f $(DOC_DOC)/Kconfig.collected ;          \
         fi
endif
ifneq ($(strip $(doc_clean_hook)),)
	(cd $(DOC_DOC);              \
               test -x $(doc_clean_hook) && $(doc_clean_hook))
endif
	-gzip -9qfr $(DOC_DOC)
	-find $(DOC_DOC)      -type f -name \*.gz -perm +111 -exec gunzip {} \;
	-find $(DOC_DOC)/html -type f -name \*.gz            -exec gunzip {} \;
	$(install_file) $(DEBDIR)/pkg/doc/copyright $(DOC_DOC)/copyright
	sed -e 's/=P/$(d_package)/g' -e 's/=V/$(version)/g' \
		$(DEBDIR)/pkg/doc/postinst >        $(DOC_TOP)/DEBIAN/postinst
	chmod 755                                   $(DOC_TOP)/DEBIAN/postinst
	dpkg-gencontrol -isp -p$(d_package)       -P$(DOC_TOP)/
	chmod -R og=rX                              $(DOC_TOP)
	chown -R root:root                          $(DOC_TOP)
	dpkg --build                                $(DOC_TOP) $(DEB_DEST)
	rm -rf                                      $(DOC_TOP)
	echo done >  stamp-doc
endif

kernel-image kernel_image: stamp-image
stamp-image: configure build kernel-image-deb
# % make config
# % make-kpkg build
# % sudo make -f debian/rules kernel-image-deb
# seems to create a working .deb with a kernel that gives the correct
# user name (as opposed to root@...)
kernel-image-deb: stamp-debian stamp-configure
	$(eval $(deb_rule))
ifeq ($(strip $(int_am_root)),)
ifeq ($(strip $(ROOT_CMD)),)
	@echo need root privileges; exit 1
else
	$(ROOT_CMD) $(run_command) real_stamp_image
endif
else
	$(run_command) real_stamp_image
endif

real_stamp_image: stamp-debian stamp-configure
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
ifneq ($(strip $(UTS_RELEASE_VERSION)),$(strip $(version)))
	@echo "The UTS Release version in include/linux/version.h $(UTS_RELEASE_VERSION) does not match current version $(version), reconfiguring."
	touch Makefile
endif
	rm -f -r ./$(IMAGE_TOP) ./$(IMAGE_TOP).deb
	$(eval $(which_debdir))
	$(make_directory) $(IMAGE_TOP)/DEBIAN
	$(make_directory) $(IMAGE_TOP)/$(IMAGEDIR)
	$(make_directory) $(IMAGE_DOC)
ifneq ($(strip $(KERNEL_ARCH)),um)
  ifneq ($(strip $(KERNEL_ARCH)),xen)
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g'  -e 's@=B@$(KERNEL_ARCH)@g'    \
         $(DEBDIR)/pkg/image/postinst > $(IMAGE_TOP)/DEBIAN/postinst
	chmod 755 $(IMAGE_TOP)/DEBIAN/postinst
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
         $(DEBDIR)/pkg/image/postrm > $(IMAGE_TOP)/DEBIAN/postrm
	chmod 755 $(IMAGE_TOP)/DEBIAN/postrm
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
         $(DEBDIR)/pkg/image/preinst > $(IMAGE_TOP)/DEBIAN/preinst
	chmod 755 $(IMAGE_TOP)/DEBIAN/preinst
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
         $(DEBDIR)/pkg/image/prerm > $(IMAGE_TOP)/DEBIAN/prerm
	chmod 755 $(IMAGE_TOP)/DEBIAN/prerm
  else
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
          $(DEBDIR)/pkg/virtual/xen/postinst > $(IMAGE_TOP)/DEBIAN/postinst
	chmod 755 $(IMAGE_TOP)/DEBIAN/postinst
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
         $(DEBDIR)/pkg/virtual/xen/prerm > $(IMAGE_TOP)/DEBIAN/prerm
	chmod 755 $(IMAGE_TOP)/DEBIAN/prerm
  endif
else
	$(make_directory) $(UML_DIR)
	$(make_directory) $(MAN1DIR)
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's@=B@$(KERNEL_ARCH)@g'     \
            -e 's/=S/$(no_symlink)/g' -e 's/=OF/$(AM_OFFICIAL)/g'    \
          $(DEBDIR)/pkg/virtual/um/postinst > $(IMAGE_TOP)/DEBIAN/postinst
	chmod 755 $(IMAGE_TOP)/DEBIAN/postinst
	sed -e 's/=V/$(version)/g'    -e 's/=B/$(link_in_boot)/g'    \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'     -e 's/=L/$(loader)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g'                                \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
          $(DEBDIR)/pkg/virtual/um/prerm > $(IMAGE_TOP)/DEBIAN/prerm
	chmod 755 $(IMAGE_TOP)/DEBIAN/prerm
	$(install_file) $(DEBDIR)/docs/linux.1 $(MAN1DIR)/linux-$(version).1
	gzip -9fq                              $(MAN1DIR)/linux-$(version).1
endif
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
	$(install_file) Documentation/Changes $(IMAGE_DOC)/
	gzip -9qf $(IMAGE_DOC)/Changes
endif
	$(install_file) debian/changelog        $(IMAGE_DOC)/changelog.Debian
	gzip -9qf                               $(IMAGE_DOC)/changelog.Debian
ifdef loaderdoc
	$(install_file) $(DEBDIR)/docs/ImageLoaders$(loaderdoc)  $(IMAGE_DOC)/$(loaderdoc)
	gzip -9qf                                                $(IMAGE_DOC)/$(loaderdoc)
endif
	$(install_file) $(DEBDIR)/pkg/image/README   $(IMAGE_DOC)/debian.README
	gzip -9qf                                    $(IMAGE_DOC)/debian.README
	$(install_file) $(DEBDIR)/pkg/image/copyrigh $(IMAGE_DOC)/copyright
	echo "This was produced by kernel-package version $(kpkg_version)." > \
	           $(IMAGE_DOC)/Buildinfo
	chmod 0644 $(IMAGE_DOC)/Buildinfo
	$(install_file) $(config)        $(INT_IMAGE_DESTDIR)/config-$(version)
	$(install_file) conf.vars        $(IMAGE_DOC)/conf.vars
	gzip -9qf                        $(IMAGE_DOC)/conf.vars
	$(install_file) debian/buildinfo $(IMAGE_DOC)/buildinfo
	gzip -9qf                        $(IMAGE_DOC)/buildinfo
	if test -f debian/official && test -f debian/README.Debian ; then \
           $(install_file) debian/README.Debian  $(IMAGE_DOC)/README.Debian ; \
         gzip -9qf                               $(IMAGE_DOC)/README.Debian;\
	fi
	if test -f README.Debian ; then \
           $(install_file) README.Debian $(IMAGE_DOC)/README.Debian.1st;\
           gzip -9qf                     $(IMAGE_DOC)/README.Debian.1st;\
	fi
	if test -f Debian.src.changelog; then \
	  $(install_file) Debian.src.changelog  $(IMAGE_DOC)/; \
           gzip -9qf                             $(IMAGE_DOC)/Debian.src.changelog;\
	fi
ifeq ($(strip $(HAVE_EXTRA_DOCS)),YES)
	$(install_file) $(extra_docs) 	         $(IMAGE_DOC)/
endif
ifneq ($(filter kfreebsd-gnu, $(DEB_HOST_GNU_SYSTEM)):$(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),:)
  ifeq  ($(DEB_HOST_GNU_SYSTEM):$(strip $(HAVE_NEW_MODLIB)),linux:)
	$(mod_inst_cmds)
  else
# could have also said DEPMOD=/bin/true instead of moving files
    ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
      ifneq ($(strip $(KERNEL_CROSS)),)
	mv System.map System.precious
      endif
	$(MAKE) $(EXTRAV_ARG) INSTALL_MOD_PATH=$(INSTALL_MOD_PATH)           \
                $(CROSS_ARG) ARCH=$(KERNEL_ARCH) modules_install
      ifneq ($(strip $(KERNEL_CROSS)),)
	mv System.precious System.map
      endif
    else
      ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
	mkdir -p $(INSTALL_MOD_PATH)/boot/defaults
	install -o root -g root -m 644                        \
                $(architecture)/conf/GENERIC.hints            \
                $(INSTALL_MOD_PATH)/boot/device.hints
	install -o root -g root -m 644 boot/forth/loader.conf \
                         $(INSTALL_MOD_PATH)/boot/loader.conf
	touch $(INSTALL_MOD_PATH)/boot/loader.conf
	install -o root -g root -m 644 boot/forth/loader.conf \
                $(INSTALL_MOD_PATH)/boot/defaults/loader.conf
	$(PMAKE) -C $(architecture)/compile/GENERIC install \
                    DESTDIR=$(INSTALL_MOD_PATH)
      endif
    endif
  endif
	test ! -e $(IMAGE_TOP)/lib/modules/$(version)/source ||                        \
	   mv $(IMAGE_TOP)/lib/modules/$(version)/source ./debian/source-link
	test ! -e $(IMAGE_TOP)/lib/modules/$(version)/build ||                         \
	   mv $(IMAGE_TOP)/lib/modules/$(version)/build ./debian/build-link
  ifeq ($(strip $(KERNEL_ARCH)),um)
	-depmod -q -FSystem.map -b $(IMAGE_TOP) \
           $(version)-$$(sed q include/linux/version.h | sed s/\"//g | awk -F\- '{print $$2}')
  else
    ifeq ($(DEB_BUILD_GNU_TYPE),$(DEB_HOST_GNU_TYPE))
	-depmod -q -FSystem.map -b $(IMAGE_TOP) $(version);
    endif
  endif
	test ! -e ./debian/source-link ||                                              \
	   mv ./debian/source-link $(IMAGE_TOP)/lib/modules/$(version)/source
	test ! -e  ./debian/build-link ||                                              \
	   mv  ./debian/build-link $(IMAGE_TOP)/lib/modules/$(version)/build

endif
ifeq ($(strip $(NEED_DIRECT_GZIP_IMAGE)),YES)
	gzip -9vc $(kimagesrc) > $(kimagedest)
else
	cp $(kimagesrc) $(kimagedest)
endif
ifeq ($(strip $(KERNEL_ARCH)),um)
	chmod 755 $(kimagedest);
ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
	strip --strip-unneeded --remove-section=.note --remove-section=.comment  $(kimagedest);
endif
else
	chmod 644 $(kimagedest);
endif
ifeq ($(strip $(HAVE_COFF_IMAGE)),YES)
	cp $(coffsrc)   $(coffdest)
	chmod 644       $(coffdest)
endif
ifeq ($(strip $(int_install_vmlinux)),YES)
ifneq ($(strip $(kelfimagesrc)),)
	cp $(kelfimagesrc) $(kelfimagedest)
	chmod 644 $(kelfimagedest)
endif
endif
	if test -d $(SRCTOP)/debian/image.d ; then                             \
             IMAGE_TOP=$(IMAGE_TOP) version=$(version)                          \
                   run-parts --verbose $(SRCTOP)/debian/image.d ;               \
         fi
	if [ -x debian/post-install ]; then                                    \
		IMAGE_TOP=$(IMAGE_TOP) STEM=$(INT_STEM) version=$(version)    \
			debian/post-install;                                  \
	fi
ifeq ($(strip $(NEED_IMAGE_POST_PROCESSING)),YES)
	if grep $(IMAGE_POST_PROCESS_TARGET) $(IMAGE_POST_PROCESS_DIR)/Makefile 2>&1 >/dev/null; then \
	    $(MAKE) INSTALL_MKVMLINUZ=$(INSTALL_MKVMLINUZ_PATH) 		            \
	    ARCH=$(KERNEL_ARCH) -C $(IMAGE_POST_PROCESS_DIR) $(IMAGE_POST_PROCESS_TARGET);  \
	fi
endif
ifneq ($(strip $(image_clean_hook)),)
	(cd $(IMAGE_TOP);              \
               test -x $(image_clean_hook) && $(image_clean_hook))
endif
	test ! -s applied_patches || cp applied_patches                        \
                        $(INT_IMAGE_DESTDIR)/patches-$(version)
	test ! -s applied_patches || chmod 644                                 \
                        $(INT_IMAGE_DESTDIR)/patches-$(version)
ifneq ($(strip $(KERNEL_ARCH)),um)
	test ! -f System.map ||  cp System.map                         \
                        $(INT_IMAGE_DESTDIR)/System.map-$(version);
	test ! -f System.map ||  chmod 644                             \
                        $(INT_IMAGE_DESTDIR)/System.map-$(version);
else
	if [ -d $(INSTALL_MOD_PATH)/lib/modules ] ; then               \
          find $(INSTALL_MOD_PATH)/lib/modules/ -type f -print0 |      \
	   xargs -0ri mv {} $(UML_DIR)/ ;                               \
        fi
	rm -rf $(INSTALL_MOD_PATH)/lib
endif
	# For LKCD enabled kernels
	test ! -f Kerntypes ||  cp Kerntypes                                   \
                        $(INT_IMAGE_DESTDIR)/Kerntypes-$(version)
	test ! -f Kerntypes ||  chmod 644                                      \
                        $(INT_IMAGE_DESTDIR)/Kerntypes-$(version)
ifeq ($(strip $(delete_build_link)),YES)
	rm -f $(IMAGE_TOP)/lib/modules/$(version)/build
endif
	dpkg-gencontrol -DArchitecture=$(DEB_HOST_ARCH) -isp                   \
                        -p$(i_package) -P$(IMAGE_TOP)/
	chmod -R og=rX $(IMAGE_TOP)
	chown -R root:root $(IMAGE_TOP)
	dpkg --build $(IMAGE_TOP) $(DEB_DEST)
	rm -f -r $(IMAGE_TOP)
ifeq ($(strip $(do_clean)),YES)
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) clean
	rm -f stamp-build
endif
	echo done >  stamp-image

# This for STOP_FOR_BIN86
endif

# This endif is for HAVE_VALID_PACKAGE_VERSION
endif

#This  endif is for IN_KERNEL_DIR
endif


# only generate module image packages
modules-image modules_image: configure
ifeq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	@echo Modules not configured, so not making $@
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	-for module in $(valid_modules) ; do                       \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(version)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             ARCH="$(KERNEL_ARCH)"                  \
                             KDREV="$(debian)" kdist_image; then    \
                  echo "Module $$module processed fine";            \
              else                                                  \
                   echo "Module $$module failed.";                  \
                   if [ "X$(strip $(ROOT_CMD))" != "X" ]; then      \
                      echo "Perhaps $$module does not understand --rootcmd?";  \
                      echo "If you see messages that indicate that it is not"; \
                      echo "in fact being built as root, please file a bug ";  \
                      echo "against $$module.";                     \
                   fi;                                              \
                   echo "Hit return to Continue";                   \
		 read ans;                                        \
              fi;                                                   \
	     );                                                    \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                       \
        done
endif

# generate the modules packages and sign them
modules: configure
ifeq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	@echo Modules not configured, so not making $@
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	-for module in $(valid_modules) ; do                       \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(version)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             ARCH=$(KERNEL_ARCH)                    \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             KDREV="$(debian)" kdist; then          \
                  echo "Module $$module processed fine";            \
              else                                                  \
                   echo "Module $$module failed.";                  \
                   if [ "X$(strip $(ROOT_CMD))" != "X" ]; then      \
                      echo "Perhaps $$module does not understand --rootcmd?";  \
                      echo "If you see messages that indicate that it is not"; \
                      echo "in fact being built as root, please file a bug ";  \
                      echo "against $$module.";                     \
                   fi;                                              \
                   echo "Hit return to Continue?";                  \
		 read ans;                                          \
              fi;                                                   \
	     );                                                     \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                       \
        done
endif

# configure the modules packages
modules-config modules_config: configure
ifeq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	@echo Modules not configured, so not making $@
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(version)"; exit 1)
endif
	-for module in $(valid_modules) ; do                       \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(version)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             ARCH=$(KERNEL_ARCH)                    \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             KDREV="$(debian)" kdist_configure; then\
                  echo "Module $$module configured fine";           \
              else                                                  \
                   echo "Module $$module failed to configure";      \
                   echo "Hit return to Continue?";                  \
		 read ans;                                        \
              fi;                                                   \
	     );                                                    \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                      \
        done
endif

modules-clean modules_clean: .config
ifeq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	@echo Modules not configured, so not making $@
else
	-for module in $(valid_modules); do                        \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(version)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             ARCH=$(KERNEL_ARCH)                    \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             KDREV="$(debian)" kdist_clean; then    \
                  echo "Module $$module cleaned";                   \
              else                                                  \
                   echo "Module $$module failed to clean up";       \
                   echo "Hit return to Continue?";                  \
		 read ans;                                          \
              fi;                                                   \
	     );                                                     \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                       \
        done
endif


source diff:
	@echo >&2 'source and diff are obsolete - use dpkg-source -b'; false

define mod_inst_cmds
        @(                                                           \
        MODLIB=$(INSTALL_MOD_PATH)/lib/modules/$(version);           \
        cd modules;                                                  \
        MODULES="";                                                  \
        inst_mod() { These="$$(cat $$1)"; MODULES="$$MODULES $$These"; \
                mkdir -p $$MODLIB/$$2; cp $$These $$MODLIB/$$2;               \
                echo Installing modules under $$MODLIB/$$2; \
        }; \
                                                                               \
	if [ -f BLOCK_MODULES    ]; then inst_mod BLOCK_MODULES    block; fi; \
	if [ -f NET_MODULES      ]; then inst_mod NET_MODULES      net;   fi; \
	if [ -f IPV4_MODULES     ]; then inst_mod IPV4_MODULES     ipv4;  fi; \
	if [ -f IPV6_MODULES     ]; then inst_mod IPV6_MODULES     ipv6;  fi; \
         if [ -f ATM_MODULES      ]; then inst_mod ATM_MODULES      atm;   fi; \
	if [ -f SCSI_MODULES     ]; then inst_mod SCSI_MODULES     scsi;  fi; \
	if [ -f FS_MODULES       ]; then inst_mod FS_MODULES       fs;    fi; \
	if [ -f NLS_MODULES      ]; then inst_mod NLS_MODULES      fs;    fi;        \
	if [ -f CDROM_MODULES    ]; then inst_mod CDROM_MODULES    cdrom; fi;        \
	if [ -f HAM_MODULES      ]; then inst_mod HAM_MODULES      net;   fi;        \
	if [ -f SOUND_MODULES    ]; then inst_mod SOUND_MODULES    sound; fi;        \
	if [ -f VIDEO_MODULES    ]; then inst_mod VIDEO_MODULES    video; fi;        \
	if [ -f FC4_MODULES      ]; then inst_mod FC4_MODULES      fc4;   fi;        \
	if [ -f IRDA_MODULES     ]; then inst_mod IRDA_MODULES     net;   fi;        \
         if [ -f USB_MODULES      ]; then inst_mod USB_MODULES      usb;   fi;        \
         if [ -f SK98LIN_MODULES  ]; then inst_mod SK98LIN_MODULES  net;   fi;        \
         if [ -f SKFP_MODULES     ]; then inst_mod SKFP_MODULES     net;   fi;        \
         if [ -f IEEE1394_MODULES ]; then inst_mod IEEE1394_MODULES ieee1394; fi;     \
         if [ -f PCMCIA_MODULES   ]; then inst_mod PCMCIA_MODULES pcmcia;   fi;       \
         if [ -f PCMCIA_NET_MODULES ]; then inst_mod PCMCIA_NET_MODULES pcmcia; fi;   \
         if [ -f PCMCIA_CHAR_MODULES ]; then inst_mod PCMCIA_CHAR_MODULES pcmcia; fi; \
         if [ -f PCMCIA_SCSI_MODULES ]; then inst_mod PCMCIA_SCSI_MODULES pcmcia; fi; \
                                                                                      \
        for f in *.o; do [ -r $$f ] && echo $$f; done > .allmods; \
        echo $$MODULES | tr ' ' '\n' | sort | comm -23 .allmods - > .misc; \
        if [ -s .misc ]; then inst_mod .misc misc; fi; \
        rm -f .misc .allmods; \
        )
endef

# 		2.0.38	2.2.12	2.3.1
# BLOCK_MODULES	X	X	X
# NET_MODULES	X	X	X
# IPV4_MODULES	X	X	X
# IPV6_MODULES		X	X
# ATM_MODULES			X
# SCSI_MODULES	X	X	X
# FS_MODULES	X	X	X
# NLS_MODULES		X	X
# CDROM_MODULES	X	X	X
# HAM_MODULES		X	X
# SOUND_MODULES		X	X
# VIDEO_MODULES		X	X
# FC4_MODULES		X	X
# IRDA_MODULES		X	X
# USB_MODULES			X
