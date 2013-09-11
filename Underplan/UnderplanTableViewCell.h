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

#define CELL_BORDER_SIZE 0
#define BOTTOM_BORDER_PADDING 16
#define BOTTOM_BORDER_SIZE 2

@interface UnderplanTableViewCell : UITableViewCell

@property (copy, nonatomic) NSString *itemId;
@property (assign, nonatomic) BOOL loaded;
@property (retain, nonatomic) UIView *lowerLine;
@property (retain, nonatomic) UIView *upperLine;

@property (retain, nonatomic) UnderplanItemDetailsView *detailsView;
@property (retain, nonatomic) UITextView *mainText;
@property (retain, nonatomic) UIImageView *contentImage;

- (void)initView;
- (int)cellHeight:(NSString *)text;

@end
