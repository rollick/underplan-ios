//
//  GroupItemViewCell.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UnderplanTableViewCell.h"

@interface GroupItemViewCell : UITableViewCell

@property (copy, nonatomic) NSString *itemId;
@property (retain, nonatomic) UILabel *description;
@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UIView *containerView;

- (int)cellHeight:(NSString *)text;

@end
