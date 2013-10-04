//
//  UnderplanActivityViewCell.h
//  Underplan
//
//  Created by Mark Gallop on 2/10/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTableViewCell.h"
#import "UnderplanActivityView.h"

@interface UnderplanActivityViewCell : UnderplanTableViewCell
{
    UnderplanActivityViewStyle _style;
}

@property (retain, nonatomic) UnderplanActivityView *mainView;

@end
