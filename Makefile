PACKAGE_VERSION = 1.6.3

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:8.0
	ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortFixReal
EmojiPortFixReal_FILES = TweakReal.xm ../EmojiPort-PS/UIKBTreeHack.xm
EmojiPortFixReal_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
EmojiPortFixReal_EXTRA_FRAMEWORKS = CydiaSubstrate
EmojiPortFixReal_LIBRARIES = EmojiLibrary
EmojiPortFixReal_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk

ifneq ($(SIMULATOR),1)
TWEAK_NAME = EmojiPortFix
EmojiPortFix_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
endif

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/EmojiPortFix.dylib
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject/EmojiPortFix.dylib
	@cp -v $(PWD)/EmojiPortFix.plist /opt/simject
endif
