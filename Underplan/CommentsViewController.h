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

#import "UnderplanActivityAwareDelegate.h"

@interface CommentsViewController : UnderplanViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (assign, nonatomic) id <UnderplanActivityAwareDelegate> delegate;

- (id)initWithDelegate:(id <UnderplanActivityAwareDelegate>)aDelegate;

@end
