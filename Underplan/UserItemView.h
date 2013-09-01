//
//  UserItemView.h
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ItemDetailsView.h"
#import "UnderplanTableViewCell.h"

#define CELL_BORDER_SIZE 0

@interface UserItemView : UnderplanTableViewCell

@property (assign, nonatomic) BOOL loaded;
@property (copy, nonatomic) NSString *itemId;
@property (retain, nonatomic) ItemDetailsView *detailsView;
@property (retain, nonatomic) UITextView *mainText;
@property (retain, nonatomic) UIImageView *contentImage;

- (CGFloat)textHeight:(NSString *)text;
- (int)cellHeight:(NSString *)text;

@end
