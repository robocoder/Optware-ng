###########################################################
#
# hpijs
#
###########################################################

# You must replace "hpijs" and "HPIJS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# HPIJS_VERSION, HPIJS_SITE and HPIJS_SOURCE define
# the upstream location of the source code for the package.
# HPIJS_DIR is the directory which is created when the source
# archive is unpacked.
# HPIJS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
HPIJS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/hpinkjet/
HPIJS_VERSION=2.1.4
HPIJS_SOURCE=hpijs-$(HPIJS_VERSION).tar.gz
HPIJS_DIR=hpijs-$(HPIJS_VERSION)
HPIJS_UNZIP=zcat
HPIJS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HPIJS_DESCRIPTION=Printer support for HP printer
HPIJS_SECTION=Printing
HPIJS_PRIORITY=optional
HPIJS_DEPENDS=libstdc++,cups
HPIJS_CONFLICTS=

#
# HPIJS_IPK_VERSION should be incremented when the ipk changes.
#
HPIJS_IPK_VERSION=1

#
# HPIJS_CONFFILES should be a list of user-editable files
HPIJS_CONFFILES=

#
# HPIJS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HPIJS_PATCHES=$(HPIJS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HPIJS_CPPFLAGS=
HPIJS_LDFLAGS=

#
# HPIJS_BUILD_DIR is the directory in which the build is done.
# HPIJS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HPIJS_IPK_DIR is the directory in which the ipk is built.
# HPIJS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HPIJS_BUILD_DIR=$(BUILD_DIR)/hpijs
HPIJS_SOURCE_DIR=$(SOURCE_DIR)/hpijs
HPIJS_IPK_DIR=$(BUILD_DIR)/hpijs-$(HPIJS_VERSION)-ipk
HPIJS_IPK=$(BUILD_DIR)/hpijs_$(HPIJS_VERSION)-$(HPIJS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hpijs-source hpijs-unpack hpijs hpijs-stage hpijs-ipk hpijs-clean hpijs-dirclean hpijs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HPIJS_SOURCE):
	$(WGET) -P $(DL_DIR) $(HPIJS_SITE)/$(HPIJS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hpijs-source: $(DL_DIR)/$(HPIJS_SOURCE) $(HPIJS_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(HPIJS_BUILD_DIR)/.configured: $(DL_DIR)/$(HPIJS_SOURCE) $(HPIJS_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(HPIJS_DIR) $(HPIJS_BUILD_DIR)
	$(HPIJS_UNZIP) $(DL_DIR)/$(HPIJS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(HPIJS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(HPIJS_DIR) -p1
	mv $(BUILD_DIR)/$(HPIJS_DIR) $(HPIJS_BUILD_DIR)
	(cd $(HPIJS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HPIJS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HPIJS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	touch $(HPIJS_BUILD_DIR)/.configured

hpijs-unpack: $(HPIJS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HPIJS_BUILD_DIR)/.built: $(HPIJS_BUILD_DIR)/.configured
	rm -f $(HPIJS_BUILD_DIR)/.built
	$(MAKE) -C $(HPIJS_BUILD_DIR)
	touch $(HPIJS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
hpijs: $(HPIJS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HPIJS_BUILD_DIR)/.staged: $(HPIJS_BUILD_DIR)/.built
	rm -f $(HPIJS_BUILD_DIR)/.staged
	$(MAKE) -C $(HPIJS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(HPIJS_BUILD_DIR)/.staged

 hpijs-stage: $(HPIJS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hpijs
#
$(HPIJS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(HPIJS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: hpijs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HPIJS_PRIORITY)" >>$@
	@echo "Section: $(HPIJS_SECTION)" >>$@
	@echo "Version: $(HPIJS_VERSION)-$(HPIJS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HPIJS_MAINTAINER)" >>$@
	@echo "Source: $(HPIJS_SITE)/$(HPIJS_SOURCE)" >>$@
	@echo "Description: $(HPIJS_DESCRIPTION)" >>$@
	@echo "Depends: $(HPIJS_DEPENDS)" >>$@
	@echo "Conflicts: $(HPIJS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/etc/hpijs/...
# Documentation files should be installed in $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/doc/hpijs/...
# Daemon startup scripts should be installed in $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??hpijs
#
# You may need to patch your application to make it use these locations.
#
$(HPIJS_IPK): $(HPIJS_BUILD_DIR)/.built
	rm -rf $(HPIJS_IPK_DIR) $(BUILD_DIR)/hpijs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HPIJS_BUILD_DIR) DESTDIR=$(HPIJS_IPK_DIR) install
	$(STRIP_COMMAND) $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/bin/hpijs
	$(INSTALL) -d $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/etc/
	#$(INSTALL) -m 644 $(HPIJS_SOURCE_DIR)/hpijs.conf $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/etc/hpijs.conf
	$(INSTALL) -d $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	#$(INSTALL) -m 755 $(HPIJS_SOURCE_DIR)/rc.hpijs $(HPIJS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXhpijs
	$(MAKE) $(HPIJS_IPK_DIR)/CONTROL/control
	#$(INSTALL) -m 755 $(HPIJS_SOURCE_DIR)/postinst $(HPIJS_IPK_DIR)/CONTROL/postinst
	#$(INSTALL) -m 755 $(HPIJS_SOURCE_DIR)/prerm $(HPIJS_IPK_DIR)/CONTROL/prerm
	#echo $(HPIJS_CONFFILES) | sed -e 's/ /\n/g' > $(HPIJS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HPIJS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hpijs-ipk: $(HPIJS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hpijs-clean:
	-$(MAKE) -C $(HPIJS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hpijs-dirclean:
	rm -rf $(BUILD_DIR)/$(HPIJS_DIR) $(HPIJS_BUILD_DIR) $(HPIJS_IPK_DIR) $(HPIJS_IPK)

#
#
# Some sanity check for the package.
#
hpijs-check: $(HPIJS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HPIJS_IPK)
