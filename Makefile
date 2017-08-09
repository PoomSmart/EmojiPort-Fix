PACKAGE_VERSION = 1.5.10

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:8.0
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Emoji10FixReal
Emoji10FixReal_FILES = TweakReal.xm
Emoji10FixReal_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/Emoji10Fix
Emoji10FixReal_EXTRA_FRAMEWORKS = CydiaSubstrate
Emoji10FixReal_LIBRARIES = EmojiLibrary
Emoji10FixReal_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk

ifneq ($(SIMULATOR),1)
TWEAK_NAME = Emoji10Fix
Emoji10Fix_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
endif

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/Emoji10Fix.dylib
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject/Emoji10Fix.dylib
	@cp -v $(PWD)/Emoji10Fix.plist /opt/simject
endif
