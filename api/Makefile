ARCHS = arm64
TARGET := iphone:clang:latest:12.0
DEBUG = 0
FINALPACKAGE = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GMV
GMV_FILES = Tweak.mm
GMV_FRAMEWORKS = UIKit Foundation Security SystemConfiguration
GMV_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "ldrestart"
