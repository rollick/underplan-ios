//
//  UnderplanStoryItemCell.h
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTableViewCell.h"

#import "UnderplanItemDetailsView.h"
#import "UnderplanStoryView.h"

@interface UnderplanStoryItemCell : UnderplanTableViewCell

@property (retain, nonatomic) UnderplanStoryView *mainView;

@end