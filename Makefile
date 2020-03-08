export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=2222

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc
export TARGET = iphone:clang:13.0

FINALPACKAGE=1

include $(THEOS)/makefiles/common.mk

ARCHS = arm64

TWEAK_NAME = iTweak
iTweak_FILES = Tweak.xm
iTweak_LIBRARIES = MobileGestalt
#iTweak_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += itweakprefs

include $(THEOS_MAKE_PATH)/aggregate.mk
