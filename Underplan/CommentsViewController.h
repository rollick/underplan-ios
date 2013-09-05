//
//  CommentsViewController.h
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanViewController.h"

#import <UIKit/UIKit.h>
#import "UnderplanApiClient.h"

@interface CommentsViewController : UnderplanViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *comments;

@end
