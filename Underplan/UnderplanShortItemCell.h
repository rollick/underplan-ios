//
//  UnderplanShortItemCell.h
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTableViewCell.h"

#import "UnderplanItemDetailsView.h"
#import "UnderplanShortView.h"

@interface UnderplanShortItemCell : UnderplanTableViewCell
{
    ShortStyle _style;
}

@property (retain, nonatomic) UnderplanShortView *mainView;

- (void)clearActivityImage;


@end
