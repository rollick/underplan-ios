//
//  UnderplanTabBarControllerViewController.h
//  Underplan
//
//  Created by Mark Gallop on 14/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UnderplanGroupAwareDelegate.h"

#import "UnderplanBarBackgroundView.h"

#import "Activity.h"
#import "Group.h"

@interface UnderplanTabBarController : UITabBarController <UITabBarControllerDelegate, UnderplanGroupAwareDelegate>
{
    NSArray *tabBarImageNames;
}

@property (retain, nonatomic) UnderplanBarBackgroundView *colourView;
@property (strong, nonatomic) NSString *activityId;
@property (strong, nonatomic) NSString *groupId;

- (void)addNavBarAction:(NSString *)imageName aController:(UIViewController *)aController actionSelector:(SEL)actionSelector;
- (void)clearNavBarActions;
- (void)setBadgeValue:(NSString *)value onController:(id)controller;
- (void)didReceiveApiUpdate:(NSNotification *)notification;
- (void)activityWasSet;

@end
