//
//  UIViewController+BarColor.m
//  Underplan
//
//  Created by Mark Gallop on 19/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UIViewController+BarColor.h"

#import "UIColor+Underplan.h"

@implementation UIViewController (BarColor)

- (void)setDarkBarColor
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setTintColor:[UIColor underplanDarkTextColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkTextColor]];

        if ([self.navigationController respondsToSelector:@selector(setBarBackgroundTint:)])
            [self.navigationController performSelector:@selector(setBarBackgroundTint:) withObject:[UIColor underplanDarkMenuColor] afterDelay:0];
        else
            [self.navigationController.navigationBar setBarTintColor:[UIColor underplanDarkMenuColor]];

        if ([self.tabBarController respondsToSelector:@selector(setBarBackgroundTint:)])
            [self.tabBarController performSelector:@selector(setBarBackgroundTint:) withObject:[UIColor underplanDarkMenuColor] afterDelay:0];
        else
            [self.tabBarController.tabBar setBarTintColor:[UIColor underplanDarkMenuColor]];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor underplanDarkMenuColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkMenuColor]];
    }
}

- (void)setDefaultBarColor
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryTextColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkTextColor]];

        if ([self.navigationController respondsToSelector:@selector(setBarBackgroundTint:)])
            [self.navigationController performSelector:@selector(setBarBackgroundTint:) withObject:[UIColor underplanPrimaryColor] afterDelay:0];
        else
            [self.navigationController.navigationBar setBarTintColor:[UIColor underplanPrimaryColor]];

        if ([self.tabBarController respondsToSelector:@selector(setBarBackgroundTint:)])
            [self.tabBarController performSelector:@selector(setBarBackgroundTint:) withObject:[UIColor underplanDarkMenuColor] afterDelay:0];
        else
            [self.tabBarController.tabBar setBarTintColor:[UIColor underplanDarkMenuColor]];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor underplanPrimaryColor]];
    }
}

@end
