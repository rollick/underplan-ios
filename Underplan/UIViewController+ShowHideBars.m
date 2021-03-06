//
//  UIViewController+ShowHideBars.m
//  Underplan
//
//  Created by Mark Gallop on 16/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UIViewController+ShowHideBars.h"
#import "UITabBarController+ShowHideTabBar.h"

#import <objc/runtime.h>

static void * const TimerTagKey = (void*)&TimerTagKey;

@implementation UIViewController (ShowHideBars)

@dynamic timer;

- (id)timer {
    return objc_getAssociatedObject(self, TimerTagKey);
}

- (void)setTimer:(id)newTimerTag {
    objc_setAssociatedObject(self, TimerTagKey, newTimerTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showBarsTemporarily
{
    [self.timer invalidate];
    [self showBars];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                  target:self
                                                selector:@selector(hideBars)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)showBars
{
    if ([UIApplication sharedApplication].statusBarHidden)
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    if (self.navigationController.navigationBar.hidden)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (self.tabBarController)
        [self.tabBarController showTabBar];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        [self setNeedsStatusBarAppearanceUpdate];
}

- (void)hideBars
{
    if (! [UIApplication sharedApplication].statusBarHidden)
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    if (! self.navigationController.navigationBar.hidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];

    if (self.tabBarController)
        [self.tabBarController hideTabBar];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        [self setNeedsStatusBarAppearanceUpdate];
}

@end
