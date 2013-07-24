//
//  ActivityViewController.h
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>

@interface ActivityViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *activityTitle;
@property (weak, nonatomic) IBOutlet UITextView *activityText;

@property (copy, nonatomic) NSDictionary *activity;
@property (strong, nonatomic) MeteorClient *meteor;

@end
