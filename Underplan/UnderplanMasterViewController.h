//
//  UnderplanMasterViewController.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>

@class UnderplanGroupViewController;

@interface UnderplanMasterViewController : UITableViewController

@property (strong, nonatomic) UnderplanGroupViewController *groupViewController;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MeteorClient *meteor;

@end
