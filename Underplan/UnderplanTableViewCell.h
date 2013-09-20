//
//  UnderplanTableViewCell.h
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UnderplanItemDetailsView.h"
#import "UnderplanUserItemView.h"

#define CELL_BORDER_SIZE 5
#define BOTTOM_BORDER_SIZE 2
#define CELL_CORDER_RADIUS 0

@interface UnderplanTableViewCell : UITableViewCell

@property (copy, nonatomic) NSString *itemId;
@property (assign, nonatomic) BOOL loaded;
@property (retain, nonatomic) UIView *containerView;
@property (retain, nonatomic) UIView *underLineView;

@property (assign, nonatomic) UnderplanItemDetailsView *detailsView;
@property (assign, nonatomic) UITextView *mainText;
@property (assign, nonatomic) UIImageView *contentImage;
@property (assign, nonatomic) UILabel *title;

- (void)initView;
- (int)cellHeight:(NSString *)text;

@end
