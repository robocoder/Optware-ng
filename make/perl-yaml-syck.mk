###########################################################
#
# perl-yaml-syck
#
###########################################################

PERL-YAML-SYCK_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/A/AU/AUDREYT
PERL-YAML-SYCK_VERSION=1.05
PERL-YAML-SYCK_SOURCE=YAML-Syck-$(PERL-YAML-SYCK_VERSION).tar.gz
PERL-YAML-SYCK_DIR=YAML-Syck-$(PERL-YAML-SYCK_VERSION)
PERL-YAML-SYCK_UNZIP=zcat
PERL-YAML-SYCK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-YAML-SYCK_DESCRIPTION=Fast, lightweight YAML loader and dumper.
PERL-YAML-SYCK_SECTION=util
PERL-YAML-SYCK_PRIORITY=optional
PERL-YAML-SYCK_DEPENDS=perl
PERL-YAML-SYCK_SUGGESTS=
PERL-YAML-SYCK_CONFLICTS=

PERL-YAML-SYCK_IPK_VERSION=2

PERL-YAML-SYCK_CONFFILES=

PERL-YAML-SYCK_BUILD_DIR=$(BUILD_DIR)/perl-yaml-syck
PERL-YAML-SYCK_SOURCE_DIR=$(SOURCE_DIR)/perl-yaml-syck
PERL-YAML-SYCK_IPK_DIR=$(BUILD_DIR)/perl-yaml-syck-$(PERL-YAML-SYCK_VERSION)-ipk
PERL-YAML-SYCK_IPK=$(BUILD_DIR)/perl-yaml-syck_$(PERL-YAML-SYCK_VERSION)-$(PERL-YAML-SYCK_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-YAML-SYCK_SOURCE):
	$(WGET) -P $(@D) $(PERL-YAML-SYCK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-yaml-syck-source: $(DL_DIR)/$(PERL-YAML-SYCK_SOURCE) $(PERL-YAML-SYCK_PATCHES)

$(PERL-YAML-SYCK_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-YAML-SYCK_SOURCE) $(PERL-YAML-SYCK_PATCHES) make/perl-yaml-syck.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-YAML-SYCK_DIR) $(@D)
	$(PERL-YAML-SYCK_UNZIP) $(DL_DIR)/$(PERL-YAML-SYCK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-YAML-SYCK_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-YAML-SYCK_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-YAML-SYCK_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-yaml-syck-unpack: $(PERL-YAML-SYCK_BUILD_DIR)/.configured

$(PERL-YAML-SYCK_BUILD_DIR)/.built: $(PERL-YAML-SYCK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		$(PERL_INC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-yaml-syck: $(PERL-YAML-SYCK_BUILD_DIR)/.built

$(PERL-YAML-SYCK_BUILD_DIR)/.staged: $(PERL-YAML-SYCK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-YAML-SYCK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-yaml-syck-stage: $(PERL-YAML-SYCK_BUILD_DIR)/.staged

$(PERL-YAML-SYCK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-yaml-syck" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-YAML-SYCK_PRIORITY)" >>$@
	@echo "Section: $(PERL-YAML-SYCK_SECTION)" >>$@
	@echo "Version: $(PERL-YAML-SYCK_VERSION)-$(PERL-YAML-SYCK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-YAML-SYCK_MAINTAINER)" >>$@
	@echo "Source: $(PERL-YAML-SYCK_SITE)/$(PERL-YAML-SYCK_SOURCE)" >>$@
	@echo "Description: $(PERL-YAML-SYCK_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-YAML-SYCK_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-YAML-SYCK_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-YAML-SYCK_CONFLICTS)" >>$@

$(PERL-YAML-SYCK_IPK): $(PERL-YAML-SYCK_BUILD_DIR)/.built
	rm -rf $(PERL-YAML-SYCK_IPK_DIR) $(BUILD_DIR)/perl-yaml-syck_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-YAML-SYCK_BUILD_DIR) DESTDIR=$(PERL-YAML-SYCK_IPK_DIR) install
	find $(PERL-YAML-SYCK_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-YAML-SYCK_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-YAML-SYCK_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-YAML-SYCK_IPK_DIR)/CONTROL/control
	echo $(PERL-YAML-SYCK_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-YAML-SYCK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-YAML-SYCK_IPK_DIR)

perl-yaml-syck-ipk: $(PERL-YAML-SYCK_IPK)

perl-yaml-syck-clean:
	-$(MAKE) -C $(PERL-YAML-SYCK_BUILD_DIR) clean

perl-yaml-syck-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-YAML-SYCK_DIR) $(PERL-YAML-SYCK_BUILD_DIR) $(PERL-YAML-SYCK_IPK_DIR) $(PERL-YAML-SYCK_IPK)

perl-yaml-syck-check: $(PERL-YAML-SYCK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-YAML-SYCK_IPK)
