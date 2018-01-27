###########################################################
#
# minissdpd
#
###########################################################

# You must replace "minissdpd" and "MINISSDPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MINISSDPD_VERSION, MINISSDPD_SITE and MINISSDPD_SOURCE define
# the upstream location of the source code for the package.
# MINISSDPD_DIR is the directory which is created when the source
# archive is unpacked.
# MINISSDPD_UNZIP is the command used to unzip the source.
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
MINISSDPD_SITE=http://miniupnp.free.fr/files
MINISSDPD_VERSION=1.5.20161216
MINISSDPD_SOURCE=minissdpd-$(MINISSDPD_VERSION).tar.gz
MINISSDPD_DIR=minissdpd-$(MINISSDPD_VERSION)
MINISSDPD_UNZIP=zcat
MINISSDPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINISSDPD_DESCRIPTION=SSDP daemon to speed up UPnP device discoveries
MINISSDPD_SECTION=net
MINISSDPD_PRIORITY=optional
MINISSDPD_DEPENDS=libnfnetlink, start-stop-daemon
MINISSDPD_CONFLICTS=

#
# MINISSDPD_IPK_VERSION should be incremented when the ipk changes.
#
MINISSDPD_IPK_VERSION=1

#
# MINISSDPD_CONFFILES should be a list of user-editable files
#
MINISSDPD_CONFFILES=$(TARGET_PREFIX)/etc/init.d/minissppd

#
# MINISSDPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINISSDPD_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINISSDPD_CPPFLAGS=
MINISSDPD_LDFLAGS=

#
# MINISSDPD_BUILD_DIR is the directory in which the build is done.
# MINISSDPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINISSDPD_IPK_DIR is the directory in which the ipk is built.
# MINISSDPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINISSDPD_BUILD_DIR=$(BUILD_DIR)/minissdpd
MINISSDPD_SOURCE_DIR=$(SOURCE_DIR)/minissdpd
MINISSDPD_IPK_DIR=$(BUILD_DIR)/minissdpd-$(MINISSDPD_VERSION)-ipk
MINISSDPD_IPK=$(BUILD_DIR)/minissdpd_$(MINISSDPD_VERSION)-$(MINISSDPD_IPK_VERSION)_$(TARGET_ARCH).ipk
MINISSDPD_INST_DIR=$(TARGET_PREFIX)


.PHONY: minissdpd-source minissdpd-unpack minissdpd minissdpd-stage minissdpd-ipk minissdpd-clean minissdpd-dirclean minissdpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINISSDPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(MINISSDPD_SITE)/$(MINISSDPD_SOURCE) 

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
minissdpd-source: $(DL_DIR)/$(MINISSDPD_SOURCE) $(MINISSDPD_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(MINISSDPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MINISSDPD_SOURCE) $(MINISSDPD_PATCHES) make/minissdpd.mk
	$(MAKE) libnfnetlink-stage
	rm -rf $(BUILD_DIR)/$(MINISSDPD_DIR) $(@D)
	$(MINISSDPD_UNZIP) $(DL_DIR)/$(MINISSDPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MINISSDPD_PATCHES)" ; \
		then cat $(MINISSDPD_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(MINISSDPD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MINISSDPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MINISSDPD_DIR) $(@D) ; \
	fi
	touch $@

minissdpd-unpack: $(MINISSDPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
# Miniupnpd does not use gnu automake, so we need to override the default
# search paths for the compile to use the correct cross-compiler
#
$(MINISSDPD_BUILD_DIR)/.built: $(MINISSDPD_BUILD_DIR)/.configured
	rm -f $@	
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINISSDPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINISSDPD_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		PREFIX=$(TARGET_PREFIX) \
		$(MAKE) \
	)
	touch $@

#
# This is the build convenience target.
#
minissdpd: $(MINISSDPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINISSDPD_BUILD_DIR)/.staged: $(MINISSDPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) PREFIX=$(STAGING_DIR) install
	touch $@

minissdpd-stage: $(MINISSDPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/minissdpd
#
$(MINISSDPD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: minissdpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINISSDPD_PRIORITY)" >>$@
	@echo "Section: $(MINISSDPD_SECTION)" >>$@
	@echo "Version: $(MINISSDPD_VERSION)-$(MINISSDPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINISSDPD_MAINTAINER)" >>$@
	@echo "Source: $(MINISSDPD_SITE)/$(MINISSDPD_SOURCE)" >>$@
	@echo "Description: $(MINISSDPD_DESCRIPTION)" >>$@
	@echo "Depends: $(MINISSDPD_DEPENDS)" >>$@
	@echo "Conflicts: $(MINISSDPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/etc/MINISSDPD/...
# Documentation files should be installed in $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/doc/MINISSDPD/...
# Daemon startup scripts should be installed in $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??MINISSDPD
#
# You may need to patch your application to make it use these locations.
#
$(MINISSDPD_IPK): $(MINISSDPD_BUILD_DIR)/.built
	rm -rf $(MINISSDPD_IPK_DIR) $(BUILD_DIR)/minissdpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINISSDPD_BUILD_DIR) STRIP="$(STRIP_COMMAND)" PREFIX=$(TARGET_PREFIX) DESTDIR=$(MINISSDPD_IPK_DIR) install
	rm -f $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/info/dir $(MINISSDPD_IPK_DIR)$(TARGET_PREFIX)/info/dir.old
	$(MAKE) $(MINISSDPD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINISSDPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
minissdpd-ipk: $(MINISSDPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
minissdpd-clean:
	rm -f $(MINISSDPD_BUILD_DIR)/.built
	-$(MAKE) -C $(MINISSDPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
minissdpd-dirclean:
	rm -rf $(BUILD_DIR)/$(MINISSDPD_DIR) $(MINISSDPD_BUILD_DIR) $(MINISSDPD_IPK_DIR) $(MINISSDPD_IPK)

#
# Some sanity check for the package.
#
minissdpd-check: $(MINISSDPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MINISSDPD_IPK)
