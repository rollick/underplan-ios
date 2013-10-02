//
//  UnderplanShortItemCell.h
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTableViewCell.h"

#import "UnderplanItemDetailsView.h"
#import "UnderplanActivityView.h"

@interface UnderplanShortItemCell : UnderplanTableViewCell
{
    UnderplanActivityViewStyle _style;
}

@property (retain, nonatomic) UnderplanActivityView *mainView;

- (void)clearActivityImage;


@end
