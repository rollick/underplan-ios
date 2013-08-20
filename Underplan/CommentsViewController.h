//
//  CommentsViewController.h
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanViewController.h"

#import <UIKit/UIKit.h>
#import "MeteorClient.h"
#import "MeteorClient+Extras.h"

@interface CommentsViewController : UnderplanViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MeteorClient *meteor;
@property (strong, nonatomic) NSMutableArray *comments;

@end
