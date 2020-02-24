include $(THEOS)/makefiles/common.mk

ARCHS = arm64

BUNDLE_NAME = itweakprefs
itweakprefs_FILES = ETKRootListController.m
itweakprefs_INSTALL_PATH = /Library/PreferenceBundles
itweakprefs_PRIVATE_FRAMEWORKS = Preferences
#itweakprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/itweakprefs.plist$(ECHO_END)
	# ugly workground
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/bin$(ECHO_END)
	$(ECHO_NOTHING)cp ldRun $(THEOS_STAGING_DIR)/usr/bin/ldRun$(ECHO_END)
	$(ECHO_NOTHING)chmod +s $(THEOS_STAGING_DIR)/usr/bin/ldRun$(ECHO_END)
