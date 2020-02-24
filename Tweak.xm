#import <UIKit/UIKit.h>

#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

// Declaring our Variables that will be used throughout the program
NSInteger statusBarStyle, bottomInsetSize, screenRoundness, appswitcherRoundness, bottomInsetVersion;
BOOL wantsQuickKeyboard, wantsHideIconLabel, wantsHomeBarSB, wantsHomeBarLS, wantsKeyboardDock, wantsRoundedAppSwitcher, wantsReduceRows, wantsCCGrabber, wantsRoundedCorners, wantsPIP, wantsProudLock, wantsHideSBCC, wantsLSShortcuts, wantsBatteryPercent, wants11Camera;

// Telling the iPhone that we want the fluid gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
    return 2;
}
%end

@interface CSTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@property(retain, nonatomic) UIImageView *controlCenterGlyphView; 
@end

@interface CSQuickActionsView : UIView
- (UIEdgeInsets)_buttonOutsets;
@property (nonatomic, retain) UIControl *flashlightButton; 
@property (nonatomic, retain) UIControl *cameraButton;
@end

%hook CSQuickActionsView
// Enables/Disables the lockscreen shortcuts 
- (BOOL)_prototypingAllowsButtons {
	return wantsLSShortcuts;
}
- (void)_layoutQuickActionButtons {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    int inset = [self _buttonOutsets].top;

    [self flashlightButton].frame = CGRectMake(46, screenBounds.size.height - 90 - inset, 50, 50);
    [self cameraButton].frame = CGRectMake(screenBounds.size.width - 96, screenBounds.size.height - 90 - inset, 50, 50);
}
%end

// Fix the default status bar from glitching by hiding the status bar in the CC.
%group HideSBCC
%hook CCUIStatusBarStyleSnapshot
- (BOOL)isHidden {
    return YES;
}
%end

%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
    %orig(nil, arg2);
}
%end
%end

%group batteryPercent
%hook _UIBatteryView 
- (void)setShowsPercentage:(BOOL)arg1 {
    return %orig(YES);
}
%end 

%hook _UIStatusBarStringView  
- (void)setText:(NSString *)text {
    if ([text containsString:@"%"])
        return;
    else
        %orig(text);
}     
%end
%end

// Reduce reachability sensitivity.
%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double) systemWideSwipeDownHeight {
    %orig(100);
}
%end

// Hide SpringBoard icon label.
%group noIconLabel
%hook SBIconView
- (void)setLabelHidden:(BOOL)arg1 {
    arg1 = YES;
    %orig;
}
%end
%end

// All the hooks for the iPhone X statusbar.
%group StatusBarX
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}

// + (Class)visualProviderSubclassForScreen:(id)arg1 {
//     return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
// }
%end

%hook SBIconListGridLayoutConfiguration
- (UIEdgeInsets)portraitLayoutInsets {
    UIEdgeInsets x = %orig;
    return UIEdgeInsetsMake(
        x.top + 10,
        x.left,
        x.bottom - 10,
        x.right);
}
%end
%end

// All the hooks for the iPad statusbar.
%group StatusBariPad
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if (screenRoundness > 15)
        return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
}
%end

// Fixes status bar glitch after closing control center
%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    if (screenRoundness > 15)
        %orig(CGRectSetY(frame, -20));
    else
        %orig(CGRectSetY(frame, -24));
}
%end
%end

// Hide the homebar
%hook SBFHomeGrabberSettings
- (BOOL)isEnabled {
    return wantsHomeBarSB;
} 
%end

// Hide the homebar on the lockscreen
%group hideHomeBarLS
%hook CSTeachableMomentsContainerView
- (void)setHomeAffordanceContainerView:(UIView *)arg1 {
    return;
}
%end
%end

@interface UIKeyboardInputMode : UITextInputMode
@property(retain) NSString *identifier;
@end

@interface UIKeyboardInputModeController : NSObject
@property(retain) UIKeyboardInputMode* currentInputMode;
- (NSArray *)activeInputModes;
@end

UIKeyboardInputMode *keyboardResult(UIKeyboardInputModeController *object, int a, int b) {
	UIKeyboardInputMode *currentInputMode = object.currentInputMode;
	NSArray *activeInputModes = [object activeInputModes];
	UIKeyboardInputMode *firstInputMode = [activeInputModes objectAtIndex:0];
	if ([activeInputModes count] == 1) {
		return firstInputMode;
	}
	int index = [currentInputMode.identifier isEqualToString:[firstInputMode identifier]] ? a : b;
	return [activeInputModes objectAtIndex:index];
}

// Quick change last keyboard.
%group quickKeyboard
%hook UIKeyboardInputModeController
- (UIKeyboardInputMode *)lastUsedInputMode {
	return keyboardResult(self, 0, 1);
}

- (UIKeyboardInputMode *)nextInputModeToUse {
	return keyboardResult(self, 1, 0);
}
%end

%hook UIKeyboardLayoutStar
- (BOOL)showsDedicatedEmojiKeyAlongsideGlobeButton {
	return NO;
}
- (NSString *)internationalKeyDisplayStringOnEmojiKeyboard {
	return nil;
}
%end
%end

// iPhone X keyboard.
%group KeyboardDock
// Automatically adjusts the sized depending if Barmoji is installed or not.
%hook UIKeyboardImpl
+ (UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    if (!NSClassFromString(@"BarmojiCollectionView"))
        orig.bottom = wantsKeyboardDock ? 46 : 0;
    if (orig.left == 75) {
        orig.left = 0;
        orig.right = 0;
    }
    return orig;
}
%end

// Moves the emoji and dictation icon on the keyboard.(Now lose dictation)
// Automatically adjust the location depending if Barmoji is installed or not.
%hook UIKeyboardDockView
- (CGRect)bounds {
    if (NSClassFromString(@"BarmojiCollectionView"))
        return %orig;

    CGRect bounds = %orig;
    bounds.size.height += 15;
    return bounds;
}
%end
%end

// Enables the rounded dock of the iPhone X + rounds up the cards of the app switcher.
%group roundedDock
%hook UITraitCollection
- (CGFloat)displayCornerRadius {
	return appswitcherRoundness;
}
%end
%end

// Reduces the number of rows of icons on the home screen by 1.
%group reduceRows
%hook SBIconListView
- (unsigned long long)iconRowsForCurrentOrientation {
    if (%orig < 4)
        return %orig;
    return %orig - wantsReduceRows;
}
%end
%end

// Move the control center grabber on the coversheet to a place where it is visible
%group ccGrabber
%hook CSTeachableMomentsContainerView
- (void)_layoutControlCenterGrabberAndGlyph {
    %orig;
    if (statusBarStyle == 2) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 73, 36, 46, 2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0, 0, 46, 2.5);
        self.controlCenterGlyphView.frame = CGRectMake(315, 45, 16.6, 19.3);
    } else if (statusBarStyle == 1) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 75.5, 24, 60.5, 2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0, 0, 60.5, 2.5);
        self.controlCenterGlyphView.frame = CGRectMake(320, 35, 16.6, 19.3);
    }
}
%end
%end

// Allows you to use the non-X iPhone button combinations.
%group originalButtons
%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray *lockHome = @[ @104, @101 ];
    NSArray *lockVol = @[ @104, @102, @103 ];
    if ([arg1 isEqual:lockVol]) {
        return %orig(lockHome);
    }
    %orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1, 1);
}
%end

%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
    return %orig(1, arg2);
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(NSArray *)arg1 {
    return;
}
%end
%end

// System-wide rounded screen corners.
%group roundedCorners

@interface _UIRootWindow : UIView
@property (setter=_setContinuousCornerRadius:, nonatomic) double _continuousCornerRadius;
@end

%hook _UIRootWindow
- (void)layoutSubviews {
    %orig;

    self.clipsToBounds = YES;
    self._continuousCornerRadius = screenRoundness;
}
%end

%hook SBReachabilityBackgroundView
- (double)_displayCornerRadius {
    return screenRoundness;
}
%end
%end

// Adds the bottom inset to the screen.
%group bottomInset			
%hook UIApplicationSceneSettings
- (UIEdgeInsets)safeAreaInsetsLandscapeLeft {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = bottomInsetSize;
    return _insets;
}
- (UIEdgeInsets)safeAreaInsetsLandscapeRight {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = bottomInsetSize;
    return _insets;
}
- (UIEdgeInsets)safeAreaInsetsPortrait {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = bottomInsetSize;
    return _insets;
}
%end
%end

// Enables PiP in video player.
%group MobileGestalt
%hookf(Boolean, "_MGGetBoolAnswer", CFStringRef key) {
    #define keyEqual(_key) CFEqual(key, CFSTR(_key))
    if (keyEqual("nVh/gwNpy7Jv1NOk00CMrw"))
        return wantsPIP;
    else if (keyEqual("z5G/N9jcMdgPm8UegLwbKg"))
        return wantsProudLock;
    return %orig;
}
%end

// Adds the padlock to the lockscreen.
%group ProudLock
%hook SBUIPasscodeBiometricResource
- (BOOL)hasPearlSupport {
    return YES;
}
- (BOOL)hasMesaSupport {
    return NO;
}
%end
%end

%group iPhone11Cam
%hook CAMCaptureCapabilities 
// - (BOOL)isCTMSupported {
//     return YES;
// }
- (BOOL)deviceSupportsCTM {
    return YES;
}
// - (BOOL)isCTMSupportSupressed {
//     return NO;
// }
- (BOOL)isBackDualSupported {
    return YES;
}
- (BOOL)isFrontPortraitModeSupported {
    return NO;
}
- (BOOL)isBackPortraitModeSupported {
    return NO;
}
%end

%hook CAMFlipButton
- (BOOL)_useCTMAppearance {
    return YES;
}
%end

// %hook CAMViewfinderViewController
// - (BOOL)_wantsHDRControlsVisible {
//     return NO;
// }
// %end
%end

// Adds a bottom inset to the camera app.
%group CameraFix
%hook CAMBottomBar 
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - 40));
}
%end

%hook CAMZoomControl
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - 30));
}
%end
%end

// Preferences.
void initPrefs() {
	NSString *path = @"/User/Library/Preferences/com.fionera.itweakprefs.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/itweakprefs.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.fionera.itweakprefs.plist"];
    if (prefs) {
        statusBarStyle = [[prefs objectForKey:@"statusBarStyle"] integerValue];
        bottomInsetSize = [[prefs objectForKey:@"bottomInsetSize"] integerValue];
        screenRoundness = [[prefs objectForKey:@"screenRoundness"] integerValue];
        appswitcherRoundness = [[prefs objectForKey:@"appswitcherRoundness"] integerValue];
        bottomInsetVersion = [[prefs objectForKey:@"bottomInsetVersion"] integerValue];
        wantsQuickKeyboard = [[prefs objectForKey:@"quickKeyboard"] boolValue];
        wantsHideIconLabel = [[prefs objectForKey:@"noIconLabel"] boolValue];
        wantsHomeBarSB = [[prefs objectForKey:@"homeBarSB"] boolValue];
        wantsHomeBarLS = [[prefs objectForKey:@"homeBarLS"] boolValue];
        wantsKeyboardDock = [[prefs objectForKey:@"keyboardDock"] boolValue];
        wantsRoundedAppSwitcher = [[prefs objectForKey:@"roundedAppSwitcher"] boolValue];
        wantsReduceRows = [[prefs objectForKey:@"reduceRows"] boolValue];
        wantsCCGrabber = [[prefs objectForKey:@"ccGrabber"] boolValue];
        wantsBatteryPercent = [[prefs objectForKey:@"batteryPercent"] boolValue];
        wantsRoundedCorners = [[prefs objectForKey:@"roundedCorners"] boolValue];
        wantsPIP = [[prefs objectForKey:@"PIP"] boolValue];
        wantsProudLock = [[prefs objectForKey:@"ProudLock"] boolValue];
        wantsHideSBCC = [[prefs objectForKey:@"HideSBCC"] boolValue];
        wantsLSShortcuts = [[prefs objectForKey:@"lsShortcutsEnabled"] boolValue];
        wants11Camera = [[prefs objectForKey:@"11Camera"] boolValue];
    }
}

%ctor {
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.fionera.itweakprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        initPrefs();
        loadPrefs();

        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

        if (statusBarStyle == 1) %init(StatusBariPad)
        else if (statusBarStyle == 2) %init(StatusBarX);
        else wantsHideSBCC = YES;

	    if (bottomInsetVersion == 1 || (bottomInsetVersion == 2 && [bundleIdentifier isEqualToString:@"com.tencent.xin"])) {
            %init(bottomInset)
        }
        if (wantsQuickKeyboard) %init(quickKeyboard);
        if (wantsHideIconLabel) %init(noIconLabel);
        if (!wantsHomeBarLS) %init(hideHomeBarLS);
        if (wantsHomeBarSB) {
            if ([bundleIdentifier isEqualToString:@"com.apple.camera"]) %init(CameraFix);
        }
        if (wants11Camera && [bundleIdentifier isEqualToString:@"com.apple.camera"]) {
            %init(iPhone11Cam);
        }
        %init(KeyboardDock);
        
        if (wantsRoundedAppSwitcher) %init(roundedDock);
        %init(reduceRows);
        if (wantsCCGrabber) %init(ccGrabber);
        %init(originalButtons);
        if (wantsRoundedCorners) %init(roundedCorners);
        %init(MobileGestalt);
        if (wantsHideSBCC) %init(HideSBCC);
        if (wantsBatteryPercent) %init(batteryPercent);
        if (wantsProudLock) %init(ProudLock);
        
        %init(_ungrouped);
    }
}
