//
//  UnderplanView.m
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanView.h"

#import "UIColor+Underplan.h"

@implementation UnderplanView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = [UIColor whiteColor];
}

@end
