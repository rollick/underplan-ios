//
//  UnderplanTableViewCell.h
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_BORDER_SIZE 0

@interface UnderplanTableViewCell : UITableViewCell

- (void)initView;
- (int)cellHeight;

@property (retain, nonatomic) UIView *lowerLine;
@property (retain, nonatomic) UIView *upperLine;

@end
