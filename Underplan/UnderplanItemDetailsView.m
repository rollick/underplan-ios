//
//  ItemDetailsView.m
//  Underplan
//
//  Created by Mark Gallop on 28/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanItemDetailsView.h"

@implementation UnderplanItemDetailsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UnderplanItemDetailsView" owner:nil options:nil];

        for(id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UnderplanItemDetailsView class]])
            {
                self = currentObject;
                break;
            }
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
