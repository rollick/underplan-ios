//
//  BannerView.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "BannerView.h"

#import "UIColor+Underplan.h"

@implementation BannerView

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
    self.backgroundColor = [UIColor underplanNoticeColor];

    self.label = [[UILabel alloc] init];
    self.label.text = @"Story";
    self.label.textColor = [UIColor whiteColor];
    [self.label setFont:[UIFont fontWithName:@"Helvetica-Light" size:14]];
    
    [self addSubview:self.label];
    
    self.border = [[UIView alloc] init];
    self.border.backgroundColor = [UIColor underplanPrimaryDarkColor];
    
    [self addSubview:self.border];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int bannerBorder = 2;
    
    [self.border setFrame:CGRectMake(self.frame.size.width - bannerBorder, 0, self.frame.size.width, self.frame.size.height)];
    
    [self.label setFrame:CGRectMake(8.0f, 0, self.frame.size.width, self.frame.size.height)];
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
