//
//  UnderplanTabBarControllerViewController.h
//  Underplan
//
//  Created by Mark Gallop on 14/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UnderplanGroupAwareDelegate.h"

#import "Activity.h"
#import "Group.h"

@interface UnderplanTabBarController : UITabBarController <UITabBarControllerDelegate, UnderplanGroupAwareDelegate>
{
    NSArray *tabBarImageNames;
}

@property (strong, nonatomic) Activity *activity;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSString *activityId;
@property (strong, nonatomic) NSString *groupId;

- (void)setBarBackgroundTint:(UIColor *)color;
- (void)addNavBarAction:(NSString *)imageName aController:(UIViewController *)aController actionSelector:(SEL)actionSelector;
- (void)clearNavBarActions;
- (void)setBadgeValue:(NSString *)value onController:(id)controller;
- (void)didReceiveApiUpdate:(NSNotification *)notification;
- (void)activityWasSet;

@end
