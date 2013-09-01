//
//  ActivityTabBarController.h
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTabBarController : UITabBarController

@property (copy, nonatomic) NSDictionary *activity;
@property (copy, nonatomic) NSDictionary *group;

@end
