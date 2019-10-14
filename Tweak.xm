#define CHECK_TARGET
#import <dlfcn.h>
#import "../PS.h"

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiAttributesRun.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLocalization.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPortFix/EmojiPortFixReal.dylib", RTLD_LAZY);
    }
}