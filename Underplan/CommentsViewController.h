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

#import "UnderplanGroupAwareDelegate.h"

@interface CommentsViewController : UnderplanViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIView *commentView;
@property (assign, nonatomic) id <UnderplanGroupAwareDelegate> delegate;

- (id)initWithDelegate:(id <UnderplanGroupAwareDelegate>)aDelegate;

@end
