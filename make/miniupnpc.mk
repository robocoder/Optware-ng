###########################################################
#
# miniupnpc
#
###########################################################

# You must replace "miniupnpc" and "MINIUPNPC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MINIUPNPC_VERSION, MINIUPNPC_SITE and MINIUPNPC_SOURCE define
# the upstream location of the source code for the package.
# MINIUPNPC_DIR is the directory which is created when the source
# archive is unpacked.
# MINIUPNPC_UNZIP is the command used to unzip the source.
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
MINIUPNPC_SITE=http://miniupnp.free.fr/files
MINIUPNPC_VERSION=2.0.20171212
MINIUPNPC_SOURCE=miniupnpc-$(MINIUPNPC_VERSION).tar.gz
MINIUPNPC_DIR=miniupnpc-$(MINIUPNPC_VERSION)
MINIUPNPC_UNZIP=zcat
MINIUPNPC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINIUPNPC_DESCRIPTION=A sample UPnP client and control point
MINIUPNPC_SECTION=net
MINIUPNPC_PRIORITY=optional
MINIUPNPC_DEPENDS=
MINIUPNPC_CONFLICTS=

#
# MINIUPNPC_IPK_VERSION should be incremented when the ipk changes.
#
MINIUPNPC_IPK_VERSION=1

#
# MINIUPNPC_CONFFILES should be a list of user-editable files
#
MINIUPNPC_CONFFILES=

#
# MINIUPNPC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINIUPNPC_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINIUPNPC_CPPFLAGS=
MINIUPNPC_LDFLAGS=

#
# MINIUPNPC_BUILD_DIR is the directory in which the build is done.
# MINIUPNPC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINIUPNPC_IPK_DIR is the directory in which the ipk is built.
# MINIUPNPC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINIUPNPC_BUILD_DIR=$(BUILD_DIR)/miniupnpc
MINIUPNPC_SOURCE_DIR=$(SOURCE_DIR)/miniupnpc
MINIUPNPC_IPK_DIR=$(BUILD_DIR)/miniupnpc-$(MINIUPNPC_VERSION)-ipk
MINIUPNPC_IPK=$(BUILD_DIR)/miniupnpc_$(MINIUPNPC_VERSION)-$(MINIUPNPC_IPK_VERSION)_$(TARGET_ARCH).ipk
MINIUPNPC_INST_DIR=$(TARGET_PREFIX)


.PHONY: miniupnpc-source miniupnpc-unpack miniupnpc miniupnpc-stage miniupnpc-ipk miniupnpc-clean miniupnpc-dirclean miniupnpc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINIUPNPC_SOURCE):
	$(WGET) -P $(DL_DIR) $(MINIUPNPC_SITE)/$(MINIUPNPC_SOURCE) 

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
miniupnpc-source: $(DL_DIR)/$(MINIUPNPC_SOURCE) $(MINIUPNPC_PATCHES)

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
$(MINIUPNPC_BUILD_DIR)/.configured: $(DL_DIR)/$(MINIUPNPC_SOURCE) $(MINIUPNPC_PATCHES) make/miniupnpc.mk
	rm -rf $(BUILD_DIR)/$(MINIUPNPC_DIR) $(@D)
	$(MINIUPNPC_UNZIP) $(DL_DIR)/$(MINIUPNPC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MINIUPNPC_PATCHES)" ; \
		then cat $(MINIUPNPC_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(MINIUPNPC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MINIUPNPC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MINIUPNPC_DIR) $(@D) ; \
	fi
	touch $@

miniupnpc-unpack: $(MINIUPNPC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
# Miniupnpc does not use gnu automake, so we need to override the default
# search paths for the compile to use the correct cross-compiler
#
$(MINIUPNPC_BUILD_DIR)/.built: $(MINIUPNPC_BUILD_DIR)/.configured
	rm -f $@	
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIUPNPC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIUPNPC_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		PREFIX=$(TARGET_PREFIX) \
		$(MAKE) \
	)
	touch $@

#
# This is the build convenience target.
#
miniupnpc: $(MINIUPNPC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINIUPNPC_BUILD_DIR)/.staged: $(MINIUPNPC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

miniupnpc-stage: $(MINIUPNPC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/miniupnpc
#
$(MINIUPNPC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: miniupnpc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIUPNPC_PRIORITY)" >>$@
	@echo "Section: $(MINIUPNPC_SECTION)" >>$@
	@echo "Version: $(MINIUPNPC_VERSION)-$(MINIUPNPC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIUPNPC_MAINTAINER)" >>$@
	@echo "Source: $(MINIUPNPC_SITE)/$(MINIUPNPC_SOURCE)" >>$@
	@echo "Description: $(MINIUPNPC_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIUPNPC_DEPENDS)" >>$@
	@echo "Conflicts: $(MINIUPNPC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/etc/MINIUPNPC/...
# Documentation files should be installed in $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/doc/MINIUPNPC/...
# Daemon startup scripts should be installed in $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??MINIUPNPC
#
# You may need to patch your application to make it use these locations.
#
$(MINIUPNPC_IPK): $(MINIUPNPC_BUILD_DIR)/.built
	rm -rf $(MINIUPNPC_IPK_DIR) $(BUILD_DIR)/miniupnpc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINIUPNPC_BUILD_DIR) STRIP="$(STRIP_COMMAND)" PREFIX=$(TARGET_PREFIX) DESTDIR=$(MINIUPNPC_IPK_DIR) install
	rm -f $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/info/dir $(MINIUPNPC_IPK_DIR)$(TARGET_PREFIX)/info/dir.old
	$(MAKE) $(MINIUPNPC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIUPNPC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
miniupnpc-ipk: $(MINIUPNPC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
miniupnpc-clean:
	rm -f $(MINIUPNPC_BUILD_DIR)/.built
	-$(MAKE) -C $(MINIUPNPC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
miniupnpc-dirclean:
	rm -rf $(BUILD_DIR)/$(MINIUPNPC_DIR) $(MINIUPNPC_BUILD_DIR) $(MINIUPNPC_IPK_DIR) $(MINIUPNPC_IPK)

#
# Some sanity check for the package.
#
miniupnpc-check: $(MINIUPNPC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MINIUPNPC_IPK)
