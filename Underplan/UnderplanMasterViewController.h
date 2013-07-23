//
//  UnderplanMasterViewController.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnderplanDetailViewController;

@interface UnderplanMasterViewController : UITableViewController

@property (strong, nonatomic) UnderplanDetailViewController *detailViewController;

@end
