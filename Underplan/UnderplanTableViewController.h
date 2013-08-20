//
//  UnderplanTableViewController.h
//  Underplan
//
//  Created by Mark Gallop on 10/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UnderplanViewController.h"

@interface UnderplanTableViewController : UnderplanViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView* tableView;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
