//
//  GroupViewController.h
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UnderplanTabBarController.h"

#import "Group.h"

@interface GroupViewController : UnderplanTabBarController <UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@end
