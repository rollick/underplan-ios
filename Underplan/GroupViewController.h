//
//  GroupViewController.h
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewController : UITabBarController

@property (copy, nonatomic) NSDictionary *group;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@end
