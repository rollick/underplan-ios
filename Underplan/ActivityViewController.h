//
//  ActivityViewController.h
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanViewController.h"

#import <UIKit/UIKit.h>
#import "MeteorClient.h"
#import "MeteorClient+Extras.h"

@interface ActivityViewController : UnderplanViewController

@property (weak, nonatomic) IBOutlet UILabel *activityTitle;
@property (weak, nonatomic) IBOutlet UITextView *activityText;

@property (copy, nonatomic) NSDictionary *activity;
@property (strong, nonatomic) MeteorClient *meteor;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *commentsButton;

@end
