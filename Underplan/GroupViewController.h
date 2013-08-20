//
//  GroupViewController.h
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeteorClient.h"
#import "MeteorClient+Extras.h"

@interface GroupViewController : UITabBarController {
    IBOutlet UITabBar *tabBar;
}

@property (copy, nonatomic) NSDictionary *group;
@property (strong, nonatomic) MeteorClient *meteor;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@end
