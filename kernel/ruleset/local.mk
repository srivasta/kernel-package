######################### -*- Mode: Makefile-Gmake -*- ########################
## local.mk<ruleset> --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:37:46 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Sat Oct 29 00:09:40 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 4
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: d047cfca-c918-4f47-b6e2-8c7df9778b26
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
###############################################################################
testdir:
	$(checkdir)

$(eval $(which_debdir))
include $(DEBDIR)/ruleset/targets/target.mk


CONFIG-common:: stamp-conf/debian .config conf.vars testdir stamp-conf/kernel
	$(REASON)

BUILD-arch:: build/kernel
	$(REASON)

BIN/$(s_package):: binary/$(s_package)
	$(REASON)
BIN/$(i_package):: binary/$(i_package)
	$(REASON)
BIN/$(d_package):: binary/$(d_package)
	$(REASON)
BIN/$(m_package):: binary/$(m_package)
	$(REASON)
BIN/$(h_package):: binary/$(h_package)
	$(REASON)

INST/$(s_package):: install/$(s_package)
	$(REASON)
INST/$(i_package):: install/$(i_package)
	$(REASON)
INST/$(d_package):: install/$(d_package)
	$(REASON)
INST/$(m_package):: install/$(m_package)
	$(REASON)
INST/$(h_package):: install/$(h_package)
	$(REASON)

CLN-common::
	$(REASON)
	$(warn_root)
	$(eval $(deb_rule))
	$(root_run_command) real_stamp_clean

CLEAN/$(s_package)::
	-rm -rf $(TMPTOP)
CLEAN/$(i_package)::
	-rm -rf $(TMPTOP)
CLEAN/$(d_package)::
	-rm -rf $(TMPTOP)
CLEAN/$(m_package)::
	-rm -rf $(TMPTOP)
CLEAN/$(h_package)::
	-rm -rf $(TMPTOP)

buildpackage: clean CONFIG-common stamp-buildpackage
stamp-buildpackage: 
	$(REASON)
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@echo "The changelog says we are creating $(saved_version)"
	@echo "However, I thought the version is $(version)"
	exit 1
endif
	echo 'Building Package' > stamp-building
	@echo DEB_SOURCE_PACKAGE=$(DEB_SOURCE_PACKAGE)
	@echo DEB_PACKAGES=$(DEB_PACKAGES)
	@echo DEB_INDEP_PACKAGES=$(DEB_INDEP_PACKAGES)
	@echo DEB_ARCH_PACKAGES=$(DEB_ARCH_PACKAGES)
	@echo DEB_ISNATIVE=$(DEB_ISNATIVE)
	@echo DEB_VERSION=$(DEB_VERSION)
	dpkg-buildpackage -nc $(strip $(int_root_cmd)) $(strip $(int_us))  \
               $(strip $(int_uc)) -m"$(maintainer) <$(email)>" -k"$(pgp)"
	rm -f stamp-building
	echo done >  $@

debian:  stamp-conf/debian

kernel-source  kernel_source:  sanity_check install/$(s_package) binary/$(s_package) 
	$(REASON)
kernel-headers kernel_headers: sanity_check install/$(h_package) binary/$(h_package) 
	$(REASON)
kernel-manual  kernel_manual:  sanity_check install/$(m_package) binary/$(m_package) 
	$(REASON)
kernel-doc     kernel_doc:     sanity_check install/$(d_package) binary/$(d_package) 
	$(REASON)
kernel-image   kernel_image:   sanity_check install/$(i_package) binary/$(i_package) 
	$(REASON)


libc-kheaders libc_kheaders: 
	$(REASON)
	@echo This target is now obsolete.


$(eval $(which_debdir))
include $(DEBDIR)/ruleset/modules.mk

#Local variables:
#mode: makefile
#End:
