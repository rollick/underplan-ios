//
//  ActivityListController.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityViewController.h"
#import "UnderplanViewController.h"

#import "UnderplanGroupAwareDelegate.h"

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageManager.h>

#import "Group.h"

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface ActivityListViewController : UnderplanViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) ActivityViewController *activityViewController;

@property (retain, nonatomic) Group *group;
@property (retain, nonatomic) NSMutableArray *activities;
@property (retain, nonatomic) UITableView *tableView;
@property (assign, nonatomic) id <UnderplanGroupAwareDelegate> delegate;

- (void)reloadData;

@end
