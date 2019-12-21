include $(THEOS)/makefiles/common.mk

ARCHS = arm64

BUNDLE_NAME = itweakprefs
itweakprefs_FILES = L11RootListController.m
itweakprefs_INSTALL_PATH = /Library/PreferenceBundles
itweakprefs_PRIVATE_FRAMEWORKS = Preferences
#itweakprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/itweakprefs.plist$(ECHO_END)
