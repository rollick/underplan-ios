//
//  GroupViewController.h
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Group.h"

#import "UnderplanGroupAwareDelegate.h"

@interface GroupViewController : UITabBarController <UnderplanGroupAwareDelegate>

@property (retain, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@end
