ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
IGNORE_WARNINGS = 1
TARGET = iphone:clang:latest:16.5
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = destroying

destroying_FRAMEWORKS = UIKit Foundation
destroying_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function
destroying_FILES = Tweak.xm LoginOnly.mm

include $(THEOS_MAKE_PATH)/tweak.mk
