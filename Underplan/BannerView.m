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
    self.backgroundColor = [UIColor underplanPrimaryDarkColor];

    self.label = [[UILabel alloc] init];
    self.label.text = @"Story";
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [[UIColor underplanPrimaryColor] colorWithAlphaComponent:0.7f];
    [self.label setFont:[UIFont fontWithName:@"Roboto-Light" size:14]];
    
    [self addSubview:self.label];
    
    self.border = [[UIView alloc] init];
    self.border.backgroundColor = [UIColor underplanWarningColor];
    
    [self addSubview:self.border];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.border setFrame:CGRectMake(self.frame.size.width - self.bannerBorder, 0, self.frame.size.width, self.frame.size.height)];
    
    [self.label setFrame:CGRectMake(8.0f, 0, self.frame.size.width, self.frame.size.height)];
}

@end
