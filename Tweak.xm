#define CHECK_TARGET
#define NEW_EMOJI_WORKAROUND
#import "../PS.h"
#import "../EmojiLibrary/Emoji10.h"
#import "../EmojiLibrary/Header.h"
#import "../EmojiLibrary/Functions.x"

%hook UIKeyboardEmojiCategory

+ (NSInteger)numberOfCategories {
    return CATEGORIES_COUNT;
}

+ (UIKeyboardEmojiCategory *)categoryForType:(NSInteger)categoryType {
    NSArray *categories = [self categories];
    UIKeyboardEmojiCategory *categoryForType = categories[categoryType];
    NSArray *emojiForType = categoryForType.emoji;
    if (emojiForType.count)
        return categoryForType;
    NSArray *emojiArray = PrepolulatedEmoji;
    switch (categoryType) {
        case 0: {
            NSMutableArray *recents = [self emojiRecentsFromPreferences];
            if (recents) {
                categoryForType.emoji = recents;
                return categoryForType;
            }
            break;
        }
        case 1:
            emojiArray = PeopleEmoji;
            break;
        case 2:
            emojiArray = NatureEmoji;
            break;
        case 3:
            emojiArray = FoodAndDrinkEmoji;
            break;
        case 4:
            emojiArray = ActivityEmoji;
            break;
        case 5:
            emojiArray = TravelAndPlacesEmoji;
            break;
        case 6:
            emojiArray = ObjectsEmoji;
            break;
        case 7:
            emojiArray = SymbolsEmoji;
            break;
        case 8:
            emojiArray = FlagsEmoji;
            break;
    }
    NSMutableArray *_emojiArray = [NSMutableArray arrayWithCapacity:emojiArray.count];
    for (NSString *emoji in emojiArray)
        addEmoji(_emojiArray, emoji, [[self class] hasVariantsForEmoji:emoji]);
    categoryForType.emoji = _emojiArray;
    return categoryForType;
}

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emoji {
    return hasVariantsForEmoji(emoji);
}

%end

%hook UIKeyboardEmojiGraphicsTraits

- (id)initWithScreenTrait: (UIKBScreenTraits *)trait {
    self = %orig;
    CGFloat keyboardWidth = trait.keyboardWidth;
    if (keyboardWidth >= 768.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 28.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 0;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 6.0;
        MSHookIvar<CGSize>(self, "_fakeEmojiKeySize") = CGSizeMake(38.0, 42.0);
    } else if (keyboardWidth >= 736.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 30.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 34.0 / 3.0;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 5.0;
    } else if (keyboardWidth >= 667.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 32.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 7.0;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 10.0;
    } else if (keyboardWidth >= 414.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 30.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 5.0 / 3.0 - 0.5;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 10.0;
        MSHookIvar<CGSize>(self, "_fakeEmojiKeySize") = CGSizeMake(40.0, 46.0);
    } else if (keyboardWidth >= 375.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 30.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 0; // 0.5
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 1.0;
        MSHookIvar<CGSize>(self, "_fakeEmojiKeySize") = CGSizeMake(38.0, 44.0);
    } else {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 25.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = -0.5; // 0
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 7.5;
        MSHookIvar<CGSize>(self, "_fakeEmojiKeySize") = CGSizeMake(38.0, 42.0);
    }
    return self;
}

%end

%hook UIKeyboardEmojiSplitCategoryPicker

- (NSString *)titleForRow: (NSInteger)row {
    return [NSClassFromString(@"UIKeyboardEmojiCategory") displayName:row];
}

%end

static NSMutableArray <UIKeyboardEmoji *> *prepolulatedCacheEmojis = nil;
static NSMutableArray <UIKeyboardEmoji *> *prepolulatedEmojis(){
    if (prepolulatedCacheEmojis == nil) {
        prepolulatedCacheEmojis = [[NSMutableArray arrayWithCapacity:PrepolulatedEmoji.count] retain];
        for (NSString *emoji in PrepolulatedEmoji)
            addEmoji(prepolulatedCacheEmojis, emoji, [NSClassFromString(@"UIKeyboardEmojiCategory") hasVariantsForEmoji:emoji]);
    }
    return prepolulatedCacheEmojis;
}

%hook UIKeyboardEmojiCollectionInputView

- (UIKeyboardEmojiCollectionViewCell *)collectionView: (UICollectionView *)collectionView_ cellForItemAtIndexPath: (NSIndexPath *)indexPath {
    UIKeyboardEmojiCollectionView *collectionView(MSHookIvar<UIKeyboardEmojiCollectionView *>(self, "_collectionView"));
    UIKeyboardEmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kEmojiCellIdentifier" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSArray *recents = collectionView.inputController.recents;
        NSMutableArray <UIKeyboardEmoji *> *prepolulatedEmojis_ = prepolulatedEmojis();
        NSUInteger prepolulatedCount = [MSHookIvar<UIKeyboardEmojiGraphicsTraits *>(self, "_emojiGraphicsTraits")prepolulatedRecentCount];
        NSRange range = NSMakeRange(0, prepolulatedCount);
        if (recents.count) {
            NSUInteger idx = 0;
            NSMutableArray *array = [NSMutableArray arrayWithArray:recents];
            if (array.count < prepolulatedCount) {
                while (idx < prepolulatedEmojis_.count && prepolulatedCount != array.count)
                    [array addObject:prepolulatedEmojis_[idx++]];
            }
            cell.emoji = [array subarrayWithRange:range][indexPath.item];
        } else
            cell.emoji = [prepolulatedEmojis_ subarrayWithRange:range][indexPath.item];
    } else {
        NSInteger section = indexPath.section;
        UIKeyboardEmojiCategory *category = [NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:section];
        NSArray <UIKeyboardEmoji *> *emojis = category.emoji;
        cell.emoji = emojis[indexPath.item];
        if (section <= 1 || section == 4) {
            NSMutableDictionary *skinPrefs = [collectionView.inputController skinToneBaseKeyPreferences];
            if (skinPrefs && cell.emoji.variantMask == 2) {
                NSString *baseString = emojiBaseString(cell.emoji.emojiString);
                NSString *skinned = skinPrefs[baseString];
                if (skinned) {
                    cell.emoji.emojiString = skinned;
                    cell.emoji = cell.emoji;
                }
            }
        }
    }
    cell.emojiFontSize = [collectionView emojiGraphicsTraits].emojiKeyWidth;
    return cell;
}

- (NSString *)emojiBaseUnicodeString:(NSString *)string {
    return emojiBaseString(string);
}

BOOL overrideNewVariant = NO;

- (id)subTreeHitTest:(CGPoint)point {
    overrideNewVariant = YES;
    id r = %orig;
    overrideNewVariant = NO;
    return r;
}

%end

%hook UIKBTree

- (void)setRepresentedString: (NSString *)string {
    %orig(overrideKBTreeEmoji(string, overrideNewVariant));
}

%end

%ctor {
    if (isTarget(TargetTypeGUINoExtension)) {
        #if TARGET_OS_SIMULATOR
        dlopen("/opt/simject/EmojiAttributes.dylib", RTLD_LAZY);
        dlopen("/opt/simject/EmojiLocalization.dylib", RTLD_LAZY);
        #else
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiAttributesRun.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLocalization.dylib", RTLD_LAZY);
        #endif
        %init;
    }
}
