%hook BSPlatform
- (NSInteger)homeButtonType {
    return 2;
}
%end

%hook SBDashBoardQuickActionsViewController	
- (BOOL)hasFlashlight {
    return NO;
}
- (BOOL)hasCamera {
    return NO;
}
%end

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end

%hook UIStatusBar_Base
+ (Class)_implementationClass {
    return NSClassFromString(@"UIStatusBar_Modern");
}
+ (void)_setImplementationClass:(Class)arg1 {
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

%hook CCUIHeaderPocketView
- (void)setBackgroundAlpha:(double)arg1 {
    arg1 = 0.0;
    %orig;
}
%end

%hook UITraitCollection
- (CGFloat)displayCornerRadius {
    return 6;
}
%end

%hook UIRemoteKeyboardWindowHosted
- (UIEdgeInsets)safeAreaInsets {
  UIEdgeInsets orig = %orig;
  orig.bottom = 44;
  return orig; 
}
%end

%hook UIKeyboardImpl
+ (UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    orig.bottom = 44;
    return orig;
}
%end

%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect bounds = %orig;
    if (bounds.origin.y == 0) {
        bounds.origin.y -= 13;
    }
    return bounds;
}
- (void)layoutSubviews {
    %orig;
}
%end

%hook UIInputWindowController
- (UIEdgeInsets)_viewSafeAreaInsetsFromScene {
    return UIEdgeInsetsMake(0, 0, 44, 0);
}
%end

typedef enum {
    Tall=0,
    Regular=1
} NEPStatusBarHeightStyle;

NEPStatusBarHeightStyle _statusBarHeightStyle = Tall;

@interface SBDashBoardTeachableMomentsContainerView: UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@end

%hook SBDashBoardTeachableMomentsContainerView
- (void)layoutSubviews {
    %orig;
    self.controlCenterGrabberView.frame = CGRectMake(0, 0, 46, 2.5);
    self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 73, 36, 46, 2.5);
}
%end
