//
//  ActivityListController.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityViewController.h"
#import "UnderplanViewController.h"

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>
#import <SDWebImage/SDWebImageManager.h>

@interface ActivityListViewController : UnderplanViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, SDWebImageManagerDelegate>

@property (strong, nonatomic) ActivityViewController *activityViewController;

@property (copy, nonatomic) NSDictionary *group;
@property (strong, nonatomic) MeteorClient *meteor;
@property (strong, nonatomic) NSMutableArray *activities;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)reloadData;
- (void)setMeteor:(MeteorClient *)newMeteor;
- (void)setActivities:(NSMutableArray *)newActivities;

@end
