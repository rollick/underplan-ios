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
        [self.navigationController.navigationBar setBarTintColor:[UIColor underplanDarkMenuColor]];

        [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkTextColor]];
        [self.tabBarController.tabBar setBarTintColor:[UIColor underplanDarkMenuColor]];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
//        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryTextColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor underplanPrimaryColor]];

//        [self.tabBarController.tabBar setBarStyle:UIBarStyleDefault];
        [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkTextColor]];
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
