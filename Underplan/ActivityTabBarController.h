//
//  ActivityTabBarController.h
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Group.h"
#import "Activity.h"

@interface ActivityTabBarController : UITabBarController <UITabBarControllerDelegate>

@property (strong, nonatomic) NSString *activityId;
@property (strong, nonatomic) Activity *activity;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSArray *comments;

- (void)setBadgeValue:(NSString *)value onController:(id)controller;

@end
