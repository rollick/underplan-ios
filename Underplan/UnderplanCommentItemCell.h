//
//  UnderplanCommentItemCell.h
//  Underplan
//
//  Created by Mark Gallop on 2/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTableViewCell.h"

#import "UnderplanUserItemView.h"

#import "Comment.h"

@interface UnderplanCommentItemCell : UnderplanTableViewCell

@property (retain, nonatomic) UnderplanUserItemView *mainView;

- (void)loadComment:(Comment *)comment;

@end
