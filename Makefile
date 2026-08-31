THEOS ?= /var/mobile/theos

ARCHS = arm64 
TARGET := iphone:clang:latest:14.0

DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Brazilix
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics AudioToolbox
$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -fno-exceptions -DNDEBUG -DTWEAK_COMPILATION
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -DTWEAK_COMPILATION
$(TWEAK_NAME)_FILES = Source/Menu.mm Source/AntiCheatBypass.mm
include $(THEOS_MAKE_PATH)/tweak.mk

APPLICATION_NAME = FluoriteMax
FluoriteMax_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics AudioToolbox
FluoriteMax_CCFLAGS = -std=c++17 -fno-rtti -fno-exceptions -DNDEBUG
FluoriteMax_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value
FluoriteMax_FILES = Source/Menu.mm
include $(THEOS_MAKE_PATH)/application.mk
