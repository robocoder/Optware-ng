###########################################################
#
# perl-lexical-persistence
#
###########################################################

PERL-LEXICAL-PERSISTENCE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/R/RC/RCAPUTO
PERL-LEXICAL-PERSISTENCE_VERSION=1.023
PERL-LEXICAL-PERSISTENCE_SOURCE=Lexical-Persistence-$(PERL-LEXICAL-PERSISTENCE_VERSION).tar.gz
PERL-LEXICAL-PERSISTENCE_DIR=Lexical-Persistence-$(PERL-LEXICAL-PERSISTENCE_VERSION)
PERL-LEXICAL-PERSISTENCE_UNZIP=zcat
PERL-LEXICAL-PERSISTENCE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LEXICAL-PERSISTENCE_DESCRIPTION=Persistent lexical variable values for arbitrary calls.
PERL-LEXICAL-PERSISTENCE_SECTION=util
PERL-LEXICAL-PERSISTENCE_PRIORITY=optional
PERL-LEXICAL-PERSISTENCE_DEPENDS=perl-devel-lexalias, perl-padwalker
PERL-LEXICAL-PERSISTENCE_SUGGESTS=
PERL-LEXICAL-PERSISTENCE_CONFLICTS=

PERL-LEXICAL-PERSISTENCE_IPK_VERSION=2

PERL-LEXICAL-PERSISTENCE_CONFFILES=

PERL-LEXICAL-PERSISTENCE_BUILD_DIR=$(BUILD_DIR)/perl-lexical-persistence
PERL-LEXICAL-PERSISTENCE_SOURCE_DIR=$(SOURCE_DIR)/perl-lexical-persistence
PERL-LEXICAL-PERSISTENCE_IPK_DIR=$(BUILD_DIR)/perl-lexical-persistence-$(PERL-LEXICAL-PERSISTENCE_VERSION)-ipk
PERL-LEXICAL-PERSISTENCE_IPK=$(BUILD_DIR)/perl-lexical-persistence_$(PERL-LEXICAL-PERSISTENCE_VERSION)-$(PERL-LEXICAL-PERSISTENCE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-LEXICAL-PERSISTENCE_SOURCE):
	$(WGET) -P $(@D) $(PERL-LEXICAL-PERSISTENCE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-lexical-persistence-source: $(DL_DIR)/$(PERL-LEXICAL-PERSISTENCE_SOURCE) $(PERL-LEXICAL-PERSISTENCE_PATCHES)

$(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LEXICAL-PERSISTENCE_SOURCE) $(PERL-LEXICAL-PERSISTENCE_PATCHES) make/perl-lexical-persistence.mk
	rm -rf $(BUILD_DIR)/$(PERL-LEXICAL-PERSISTENCE_DIR) $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)
	$(PERL-LEXICAL-PERSISTENCE_UNZIP) $(DL_DIR)/$(PERL-LEXICAL-PERSISTENCE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-LEXICAL-PERSISTENCE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-LEXICAL-PERSISTENCE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-LEXICAL-PERSISTENCE_DIR) $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)
	(cd $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-lexical-persistence-unpack: $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.configured

$(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.built: $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-lexical-persistence: $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.built

$(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.staged: $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-lexical-persistence-stage: $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.staged

$(PERL-LEXICAL-PERSISTENCE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-lexical-persistence" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LEXICAL-PERSISTENCE_PRIORITY)" >>$@
	@echo "Section: $(PERL-LEXICAL-PERSISTENCE_SECTION)" >>$@
	@echo "Version: $(PERL-LEXICAL-PERSISTENCE_VERSION)-$(PERL-LEXICAL-PERSISTENCE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LEXICAL-PERSISTENCE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LEXICAL-PERSISTENCE_SITE)/$(PERL-LEXICAL-PERSISTENCE_SOURCE)" >>$@
	@echo "Description: $(PERL-LEXICAL-PERSISTENCE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LEXICAL-PERSISTENCE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LEXICAL-PERSISTENCE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LEXICAL-PERSISTENCE_CONFLICTS)" >>$@

$(PERL-LEXICAL-PERSISTENCE_IPK): $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR)/.built
	rm -rf $(PERL-LEXICAL-PERSISTENCE_IPK_DIR) $(BUILD_DIR)/perl-lexical-persistence_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR) DESTDIR=$(PERL-LEXICAL-PERSISTENCE_IPK_DIR) install
	find $(PERL-LEXICAL-PERSISTENCE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-LEXICAL-PERSISTENCE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-LEXICAL-PERSISTENCE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-LEXICAL-PERSISTENCE_IPK_DIR)/CONTROL/control
	echo $(PERL-LEXICAL-PERSISTENCE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LEXICAL-PERSISTENCE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LEXICAL-PERSISTENCE_IPK_DIR)

perl-lexical-persistence-ipk: $(PERL-LEXICAL-PERSISTENCE_IPK)

perl-lexical-persistence-clean:
	-$(MAKE) -C $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR) clean

perl-lexical-persistence-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LEXICAL-PERSISTENCE_DIR) $(PERL-LEXICAL-PERSISTENCE_BUILD_DIR) $(PERL-LEXICAL-PERSISTENCE_IPK_DIR) $(PERL-LEXICAL-PERSISTENCE_IPK)
