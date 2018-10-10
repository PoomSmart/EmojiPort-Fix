#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import <UIKit/UIKBScreenTraits.h>

%hook UIKeyboardEmojiCategory

+ (NSInteger)numberOfCategories {
    return CATEGORIES_COUNT;
}

+ (UIKeyboardEmojiCategory *)categoryForType:(PSEmojiCategory)categoryType {
    NSArray <UIKeyboardEmojiCategory *> *categories = [self categories];
    UIKeyboardEmojiCategory *categoryForType = categories[categoryType];
    NSArray <UIKeyboardEmoji *> *emojiForType = categoryForType.emoji;
    if (emojiForType.count)
        return categoryForType;
    NSArray <NSString *> *emojiArray = nil;
    switch (categoryType) {
        case IDXPSEmojiCategoryRecent: {
            NSMutableArray <UIKeyboardEmoji *> *recents = [self emojiRecentsFromPreferences];
            if (recents) {
                categoryForType.emoji = recents;
                return categoryForType;
            }
            break;
        }
        case IDXPSEmojiCategoryPeople:
            emojiArray = [PSEmojiUtilities PeopleEmoji];
            break;
        case IDXPSEmojiCategoryNature:
            emojiArray = [PSEmojiUtilities NatureEmoji];
            break;
        case IDXPSEmojiCategoryFoodAndDrink:
            emojiArray = [PSEmojiUtilities FoodAndDrinkEmoji];
            break;
        case IDXPSEmojiCategoryActivity:
            emojiArray = [PSEmojiUtilities ActivityEmoji];
            break;
        case IDXPSEmojiCategoryTravelAndPlaces:
            emojiArray = [PSEmojiUtilities TravelAndPlacesEmoji];
            break;
        case IDXPSEmojiCategoryObjects:
            emojiArray = [PSEmojiUtilities ObjectsEmoji];
            break;
        case IDXPSEmojiCategorySymbols:
            emojiArray = [PSEmojiUtilities SymbolsEmoji];
            break;
        case IDXPSEmojiCategoryFlags:
            emojiArray = [PSEmojiUtilities FlagsEmoji];
            break;
    }
    if (emojiArray) {
        NSMutableArray <UIKeyboardEmoji *> *_emojiArray = [NSMutableArray arrayWithCapacity:emojiArray.count];
        for (NSString *emojiString in emojiArray)
            [PSEmojiUtilities addEmoji:_emojiArray emojiString:emojiString withVariantMask:[PSEmojiUtilities hasVariantsForEmoji:emojiString]];
        categoryForType.emoji = _emojiArray;
    }
    return categoryForType;
}

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emoji {
    return [PSEmojiUtilities hasVariantsForEmoji:emoji];
}

%end

%hook UIKeyboardEmojiGraphicsTraits

- (id)initWithScreenTrait:(UIKBScreenTraits *)trait {
    self = %orig;
    CGFloat keyboardWidth = trait.keyboardWidth;
    if (keyboardWidth >= 1024.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 44.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 11.0;
        MSHookIvar<CGFloat>(self, "_categoryHeaderHeight") = 44.0;
        MSHookIvar<CGFloat>(self, "_inputViewLeftMostPadding") = 24.0;
        MSHookIvar<CGFloat>(self, "_inputViewRightMostPadding") = 35.0;
        MSHookIvar<CGFloat>(self, "_minimumInteritemSpacing") = 10.0;
        MSHookIvar<CGFloat>(self, "_minimumLineSpacing") = 15.0;
        MSHookIvar<CGFloat>(self, "_columnOffset") = 15.0;
        MSHookIvar<CGFloat>(self, "_sectionOffset") = 45.0;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 6.0;
        MSHookIvar<CGSize>(self, "_fakeEmojiKeySize") = CGSizeMake(64.0, 64.0);
    } else if (keyboardWidth >= 768.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 4.0;
    } else if (keyboardWidth >= 736.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 34.0 / 3.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 30.0;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 5.0;
    } else if (keyboardWidth >= 667.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 32.0;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 7.0;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 10.0;
    } else if (keyboardWidth >= 568.0) {
        MSHookIvar<CGFloat>(self, "_categorySelectedCirPadding") = 8.5;
        MSHookIvar<CGFloat>(self, "_categorySelectedCirWidth") = 25.0;
        MSHookIvar<CGFloat>(self, "_scrubViewTopPadding") = 3.0;
        MSHookIvar<CGSize>(self, "_fakeEmojiKeySize") = CGSizeMake(42.0, 33.0);
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

- (NSString *)titleForRow:(NSInteger)row {
    return [NSClassFromString(@"UIKeyboardEmojiCategory") displayName:row];
}

%end

%hook UIKeyboardEmojiCollectionInputView

- (UIKeyboardEmojiCollectionViewCell *)collectionView:(UICollectionView *)collectionView_ cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [PSEmojiUtilities collectionView:collectionView_ cellForItemAtIndexPath:indexPath inputView:self];
}

- (NSString *)emojiBaseUnicodeString:(NSString *)emojiString {
    return [PSEmojiUtilities emojiBaseString:emojiString];
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

- (void)setRepresentedString:(NSString *)string {
    %orig([PSEmojiUtilities overrideKBTreeEmoji:string overrideNewVariant:overrideNewVariant]);
}

%end

%ctor {
#if TARGET_OS_SIMULATOR
    dlopen("/opt/simject/EmojiAttributes.dylib", RTLD_LAZY);
    dlopen("/opt/simject/EmojiLocalization.dylib", RTLD_LAZY);
#endif
    %init;
}
