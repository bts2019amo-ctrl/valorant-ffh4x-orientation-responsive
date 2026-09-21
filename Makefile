
#export THEOS=/var/mobile/theos
ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
IGNORE_WARNINGS = 1
TARGET = iphone:clang:latest:16.5
THEOS_PACKAGE_SCHEME = rootless


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = destroying
#FRAMEWORK_NAME = destroying

KITTYMEMORY_SRC = $(wildcard KittyMemory/*.cpp)

destroying_FRAMEWORKS =  UIKit Foundation Security QuartzCore CoreGraphics CoreText  AVFoundation Accelerate GLKit SystemConfiguration GameController

#destroying_LDFLAGS += API/libAPIClient.a

destroying_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function

destroying_CCFLAGS = -w -std=gnu++14 -fno-rtti -fno-exceptions -DNDEBUG -Wno-module-import-in-extern-c

# Chỉ bao gồm các file nguồn .mm
destroying_RESOURCES = Resources/*

destroying_FILES = Tweak.xm ImGuiDraw.mm ImGuiView.mm  $(wildcard Tool/*.mm) $(wildcard imgui/*.cpp) $(wildcard imgui/*.mm) $(wildcard API/*.mm) $(KITTYMEMORY_SRC) $(wildcard fishhook/*.c)



# GO_EASY_ON_ME = 1

include $(THEOS_MAKE_PATH)/tweak.mk
#include $(THEOS_MAKE_PATH)/framework.mk

# Copia a dylib adicional para o staging antes de gerar o .deb rootless.
before-package::
	@mkdir -p "$(THEOS_STAGING_DIR)/Library/Application Support/destroying"
	@cp "$(THEOS_PROJECT_DIR)/empirexits.dylib" "$(THEOS_STAGING_DIR)/Library/Application Support/destroying/empirexits.dylib"
