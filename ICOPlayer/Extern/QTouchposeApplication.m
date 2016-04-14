// Copyright 2012 Todd Reed
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.



#import "QTouchposeApplication.h"
#import <QuartzCore/QuartzCore.h>

#if defined(DEBUG)


#import <objc/runtime.h> 


@interface QTouchposeApplication ()

- (void)keyWindowChanged:(UIWindow *)window;
- (void)bringTouchViewToFront;

@end

/// The QTouchposeTouchesView is an overlay view that is used as the superview for
/// QTouchposeFingerView instances.
@interface QTouchposeTouchesView : UIView
@end

@implementation QTouchposeTouchesView
@end


/// The QTouchposeFingerView is used to render a finger touches on the screen.
@interface QTouchposeFingerView : UIView

- (id)initWithPoint:(CGPoint)point
              color:(UIColor *)color
touchEndAnimationDuration:(NSTimeInterval)touchEndAnimationDuration
  touchEndTransform:(CATransform3D)touchEndTransform
   customTouchImage:(UIImage *)customTouchImage
   customTouchPoint:(CGPoint)customtouchPoint;

@end

@implementation QTouchposeFingerView
{
    CATransform3D _touchEndTransform;
    CGFloat _touchEndAnimationDuration;
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"-[%@ %@] not supported", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)removeFromSuperview
{
    [UIView animateWithDuration:_touchEndAnimationDuration animations:^{
        self.alpha = 0.0f;
        self.layer.transform = _touchEndTransform;
    } completion:^(BOOL completed){
        [super removeFromSuperview];
    }];
}

#pragma mark - QTouchposeFingerView

- (id)initWithPoint:(CGPoint)point
              color:(UIColor *)color
touchEndAnimationDuration:(NSTimeInterval)touchEndAnimationDuration
  touchEndTransform:(CATransform3D)touchEndTransform
   customTouchImage:(UIImage *)customTouchImage
   customTouchPoint:(CGPoint)customtouchPoint

{
    if (customTouchImage)
    {        
        CGRect frame = CGRectMake(point.x - customtouchPoint.x,
                                  point.y - customtouchPoint.y,
                                  customTouchImage.size.width,
                                  customTouchImage.size.height);
        
        if (self = [super initWithFrame:frame])
        {
            self.opaque = NO;
            
            UIImageView *iv = [[UIImageView alloc] initWithImage:customTouchImage];
            [self addSubview:iv];
        }
        
        return self;
    }
    else
    {
        const CGFloat kFingerRadius = 22.0f;
        
        if ((self = [super initWithFrame:CGRectMake(point.x-kFingerRadius, point.y-kFingerRadius, 2*kFingerRadius, 2*kFingerRadius)]))
        {
            self.opaque = NO;
            self.layer.borderColor = [color colorWithAlphaComponent:0.6f].CGColor;
            self.layer.cornerRadius = kFingerRadius;
            self.layer.borderWidth = 2.0f;
            self.layer.backgroundColor = [color colorWithAlphaComponent:0.4f].CGColor;

            _touchEndAnimationDuration = touchEndAnimationDuration;
            _touchEndTransform = touchEndTransform;
        }
        
        return self;
    }
}

@end

IMP SwizzleMethod(Class c, SEL sel, IMP newImplementation)
{
    Method method = class_getInstanceMethod(c, sel);
    IMP originalImplementation = method_getImplementation(method);
    if (!class_addMethod(c, sel, newImplementation, method_getTypeEncoding(method)))
        method_setImplementation(method, newImplementation);
    return originalImplementation;
}

static void (*UIWindow_orig_becomeKeyWindow)(UIWindow *, SEL);

// This method replaces -[UIWindow becomeKeyWindow] (but calls the original -becomeKeyWindow). This
// is used to move the overlay to the current key window.
static void UIWindow_new_becomeKeyWindow(UIWindow *window, SEL _cmd)
{
    QTouchposeApplication *application = (QTouchposeApplication *)[UIApplication sharedApplication];
    [application keyWindowChanged:window];
    (*UIWindow_orig_becomeKeyWindow)(window, _cmd);
}

static void (*UIWindow_orig_didAddSubview)(UIWindow *, SEL, UIView *);

// This method replaces -[UIWindow didAddSubview:] (but calls the original -didAddSubview:). This is
// used to keep the overlay view the top-most view of the window.
static void UIWindow_new_didAddSubview(UIWindow *window, SEL _cmd, UIView *view)
{
    if (![view isKindOfClass:[QTouchposeFingerView class]])
    {
        QTouchposeApplication *application = (QTouchposeApplication *)[UIApplication sharedApplication];
        [application bringTouchViewToFront];
    }
    (*UIWindow_orig_didAddSubview)(window, _cmd, view);
}


@implementation QTouchposeApplication
{
    // Dictionary of touches being displayed. Keys are UITouch pointers and values are UIView
    // pointers that represent that visually represent the touch on-screen. (A
    // CFMutableDictionaryRef is used because NSDictionary requries its keys to conform to the
    // NSCopying protocol and UITouch doesn't. We don't need to retain either the UITouch or
    // UIView instances because UITouch objects are persistent throughout a multi-touch
    // sequence, and the UIViews are retained by their superview.)
    CFMutableDictionaryRef _touchDictionary;
    UIView *_touchView;
}

#pragma mark - NSObject

+ (NSUInteger)majorSystemVersion
{
    NSArray *versionComponents = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    return [[versionComponents objectAtIndex:0] integerValue];
}

- (id)init
{
    if ((self = [super init]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidConnectNotification:) name:UIScreenDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidDisonnectNotification:) name:UIScreenDidDisconnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];        
        _touchDictionary = CFDictionaryCreateMutable(NULL, 10, NULL, NULL);
        _alwaysShowTouches = NO;
        _touchColor = [UIColor colorWithRed:0.251f green:0.424f blue:0.502f alpha:1.0f];
        _touchEndAnimationDuration = 0.5f;
        _touchEndTransform = CATransform3DMakeScale(1.5, 1.5, 1);
        
        _customTouchImage = nil;
        _customTouchPoint = CGPointZero;
        
        // In my experience, the keyboard performance is crippled when showing touches on a
        // device running iOS < 5, so by default, disable touches when the keyboard is
        // present.
        _showTouchesWhenKeyboardShown = [[self class] majorSystemVersion] >= 5;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFRelease(_touchDictionary);
}


#pragma mark - UIApplication

- (void)sendEvent:(UIEvent *)event
{
    if (_showTouches)
        [self updateTouches:[event allTouches]];
    [super sendEvent:event];
}

#pragma mark - QApplication

- (void)removeTouchesActiveTouches:(NSSet *)activeTouches
{
    CFIndex count = CFDictionaryGetCount(_touchDictionary);
    void const * keys[count];
    void const * values[count];
    CFDictionaryGetKeysAndValues(_touchDictionary, keys, values);
    for (CFIndex i = 0; i < count; ++i)
    {
        UITouch *touch = (__bridge UITouch *)keys[i];

        if (activeTouches == nil || ![activeTouches containsObject:touch])
        {
            UIView *view = (__bridge UIView *)values[i];
            CFDictionaryRemoveValue(_touchDictionary, (__bridge const void *)(touch));
            [view removeFromSuperview];
        }
    }
}

- (void)updateTouches:(NSSet *)touches
{
    for (UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:_touchView];
        UIView *fingerView = (UIView *)CFDictionaryGetValue(_touchDictionary, (__bridge const void *)(touch));
        
        if (touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded)
        {
            // Note that there seems to be a bug in iOS: we won't observe all UITouches
            // in the UITouchPhaseEnded phase, resulting in some finger views being left
            // on the screen when they shouldn't be. See
            // https://discussions.apple.com/thread/1507669?start=0&tstart=0 for other's
            // comments about this issue. No workaround is implemented here.
            
            
            if (fingerView != NULL)
            {
                // Remove the touch from the 
                CFDictionaryRemoveValue(_touchDictionary, (__bridge const void *)(touch));
                [fingerView removeFromSuperview];
            }
        }
        else
        {
            if (fingerView == NULL)
            {
                fingerView = [[QTouchposeFingerView alloc] initWithPoint:point
                                                                   color:_touchColor
                                               touchEndAnimationDuration:_touchEndAnimationDuration
                                                       touchEndTransform:_touchEndTransform
                                                        customTouchImage:self.customTouchImage
                                                        customTouchPoint:self.customTouchPoint];
                [_touchView addSubview:fingerView];
                CFDictionarySetValue(_touchDictionary, (__bridge const void *)(touch), (__bridge const void *)(fingerView));
            }
            else
            {
                if (self.customTouchImage)
                {
                    CGPoint newCenter = point;
                    newCenter.x += (self.customTouchImage.size.width / 2) - self.customTouchPoint.x;
                    newCenter.y += (self.customTouchImage.size.height / 2) - self.customTouchPoint.y;

                    fingerView.center = newCenter;
                }
                else
                {
                    fingerView.center = point;
                }
            }
        }
    }

    [self removeTouchesActiveTouches:touches];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // We intercept calls to -becomeKeyWindow and -didAddSubview of UIWindow to manage the
    // overlay view QTouchposeTouchesView and ensure it remains the top-most window.
    UIWindow_orig_didAddSubview = (void (*)(UIWindow *, SEL, UIView *))SwizzleMethod([UIWindow class], @selector(didAddSubview:), (IMP)UIWindow_new_didAddSubview);
    UIWindow_orig_becomeKeyWindow = (void (*)(UIWindow *, SEL))SwizzleMethod([UIWindow class], @selector(becomeKeyWindow), (IMP)UIWindow_new_becomeKeyWindow);

    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)screenDidConnectNotification:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)screenDidDisonnectNotification:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)keyboardDidShowNotification:(NSNotification *)notification
{
    self.showTouches = _showTouchesWhenKeyboardShown && (_alwaysShowTouches || [self hasMirroredScreen]);
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)keyWindowChanged:(UIWindow *)window
{
    if (_touchView)
        [window addSubview:_touchView];
}

- (void)bringTouchViewToFront
{
    if (_touchView)
        [_touchView.window bringSubviewToFront:_touchView];
}

- (BOOL)hasMirroredScreen
{
    BOOL hasMirroredScreen = NO;
    NSArray *screens = [UIScreen screens];

    if ([screens count] > 1)
    {
        for (UIScreen *screen in screens)
        {
            if (screen.mirroredScreen != nil)
            {
                hasMirroredScreen = YES;
                break;
            }
        }
    }
    return hasMirroredScreen;
}

- (void)setShowTouches:(BOOL)showTouches
{
    if (showTouches)
    {
        if (_touchView == nil && self.keyWindow)
        {
            UIWindow *window = self.keyWindow;
            _touchView = [[QTouchposeTouchesView alloc] initWithFrame:window.bounds];
            _touchView.backgroundColor = [UIColor clearColor];
            _touchView.opaque = NO;
            _touchView.userInteractionEnabled = NO;
            [window addSubview:_touchView];
        }
    }
    else
    {
        [self removeTouchesActiveTouches:nil];
        if (_touchView)
        {
            [_touchView removeFromSuperview];
            _touchView = nil;
        }
    }
    _showTouches = showTouches;
}

@end

#endif
