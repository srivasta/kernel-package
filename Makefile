############################ -*- Mode: Makefile -*- ###########################
## Makefile --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
## Created On       : Tue Nov 18 15:53:52 2003
## Created On Node  : glaurung.green-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Sat Dec  6 17:15:29 2003
## Last Machine Used: glaurung.green-gryphon.com
## Update Count     : 13
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
###############################################################################
prefix=
package = kernel-package

CONFLOC    := /etc/kernel-pkg.conf
LIBLOC     := /usr/share/kernel-package
MODULE_LOC := /usr/src/modules

DOCFILES = README.doc README.headers README.image README.modules \
           README.source README.tecra sample.kernel-img.conf \
           kernel_grub_conf.sh sample.posthook.sh


# where kernel-package files go to
DEBDIR     = $(LIBLOC)
DEBDIR_NAME= $(shell basename $(DEBDIR))

DOCDIR     = $(prefix)/usr/share/doc/$(package)
MAN1DIR    = $(prefix)/usr/share/man/man1
MAN5DIR    = $(prefix)/usr/share/man/man5
MAN8DIR    = $(prefix)/usr/share/man/man8
ES_MAN1DIR = $(prefix)/usr/share/man/es/man1
ES_MAN5DIR = $(prefix)/usr/share/man/es/man5
ES_MAN8DIR = $(prefix)/usr/share/man/es/man8



BASH_DIR:= $(prefix)/etc/bash_completion.d

# install commands
install_file   = install -p    -o root -g root -m 644
install_program= install -p    -o root -g root -m 755
make_directory = install -p -d -o root -g root -m 755

all build: check

check:
	perl -wc make-kpkg
	perl -wc kernel/image.preinst
	perl -wc kernel/image.postinst
	perl -wc kernel/image.postrm
	perl -wc kernel/image.prerm
	perl -wc kernel/include.postinst
	bash -n kernel/kernel_grub_conf.sh
	bash -n kernel/kernel_grub_rm.sh
	bash -n kernel/sample.posthook.sh

install:
	$(make_directory)  $(MAN1DIR)
	$(make_directory)  $(MAN5DIR)
	$(make_directory)  $(MAN8DIR)
	$(make_directory)  $(ES_MAN1DIR)
	$(make_directory)  $(ES_MAN5DIR)
	$(make_directory)  $(ES_MAN8DIR)
	$(make_directory)  $(DOCDIR)
	$(make_directory)  $(BASH_DIR)
	$(install_file)    debian/changelog             $(DOCDIR)/changelog
	$(install_file)    README                       $(DOCDIR)/README
	$(install_file)    kernel/Flavours              $(DOCDIR)/Flavours
	$(install_file)    kernel/HOWTO-Linux-2.6-Woody $(DOCDIR)/
	$(install_file)    Problems                     $(DOCDIR)/Problems
	$(install_file)    _make-kpkg                   $(BASH_DIR)/make_kpkg
	$(install_file)    Multi-Arch                   $(DOCDIR)/Multi-Arch
	$(install_file)    Rationale                    $(DOCDIR)/Rationale
	gzip -9fqr         $(DOCDIR)
	(cd $(DOCDIR);     for file in $(DOCFILES); do \
                            ln -s ../../$(package)/$$file $$file; \
                           done)
	$(install_file)    debian/copyright  	   $(DOCDIR)/copyright
	$(install_file)    kernel-pkg.conf.5 	   $(MAN5DIR)/kernel-pkg.conf.5
	$(install_file)    kernel-img.conf.5 	   $(MAN5DIR)/kernel-img.conf.5
	$(install_file)    kernel-package.5  	   $(MAN5DIR)/kernel-package.5
	$(install_file)    make-kpkg.8       	   $(MAN1DIR)/make-kpkg.1
	$(install_file)    kernel-packageconfig.8  	   $(MAN8DIR)/
	$(install_file)    kernel-pkg.conf.es.5 	   $(ES_MAN5DIR)/kernel-pkg.conf.5 
	$(install_file)    kernel-img.conf.es.5 	   $(ES_MAN5DIR)/kernel-img.conf.5
	$(install_file)    kernel-package.es.5  	   $(ES_MAN5DIR)/kernel-package.5  
	$(install_file)    make-kpkg.es.8       	   $(ES_MAN1DIR)/make-kpkg.1
	$(install_file)    kernel-packageconfig.es.8     \
                                                     $(ES_MAN8DIR)/kernel-packageconfig.8 
	gzip -9fqr         $(prefix)/usr/share/man
	$(install_file)    kernel-pkg.conf $(prefix)/etc/kernel-pkg.conf
	$(install_program) kernel-packageconfig \
		           $(prefix)/usr/sbin/kernel-packageconfig
	$(install_program) make-kpkg $(prefix)/usr/bin/make-kpkg
	(cd kernel;        tar cf - * | \
           (cd             $(prefix)/usr/share/$(package);\
                           tar xf -))
	$(install_file)    Rationale $(prefix)/usr/share/$(package)/
# Hack, tell the   rules file what version of kernel package it is
	sed -e             's/=K=V/$(version)/' kernel/rules > \
                              $(prefix)/usr/share/$(package)/rules

clean distclean:
	@echo nothing to do for clean