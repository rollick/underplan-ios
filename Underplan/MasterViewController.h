//
//  MasterViewController.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnderplanApiClient.h"

#import "UnderplanViewController.h"

@class GroupViewController;

@interface MasterViewController : UnderplanViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) GroupViewController *groupViewController;
@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIView *addGroupView;
@property (retain, nonatomic) UILabel *connectionStatusText;
@property (retain, nonatomic) UILabel *exploreLabel;

@end
