//
//  UIViewController+ShowHideBars.m
//  Underplan
//
//  Created by Mark Gallop on 16/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UIViewController+ShowHideBars.h"

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
                                                 repeats:YES];
}

- (void)showBars
{
    if (self.navigationController.navigationBar.hidden)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.tabBarController.tabBar setHidden:NO];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)hideBars
{
    if (! self.navigationController.navigationBar.hidden)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.tabBarController.tabBar setHidden:YES];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

@end
