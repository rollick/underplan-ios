//
//  MasterViewController.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>

@class GroupViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) GroupViewController *groupViewController;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusText;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MeteorClient *meteor;

@end
