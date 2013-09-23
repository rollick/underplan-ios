//
//  UnderplanTabBar.m
//  Underplan
//
//  Created by Mark Gallop on 20/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTabBar.h"

#import "UnderplanBarBackgroundView.h"

@interface UnderplanTabBar ()

@property (nonatomic, strong) CALayer *extraColorLayer;

@end

static CGFloat const kDefaultColorLayerOpacity = 0.7f;

@implementation UnderplanTabBar

- (void)setBarTintColor:(UIColor *)barTintColor
{
    [super setBarTintColor:barTintColor];
    if (self.extraColorLayer == nil) {
        UnderplanBarBackgroundView *colourView = [[UnderplanBarBackgroundView alloc] init];
        colourView.opaque = NO;
        colourView.alpha = .7f;
        colourView.backgroundColor = barTintColor;
        
        self.extraColorLayer = colourView.layer;
        //        self.extraColorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer insertSublayer:self.extraColorLayer atIndex:1];
    }
    else
    {
        for (CALayer *layer in self.layer.sublayers)
        {
            if ([layer.delegate isKindOfClass:[UnderplanBarBackgroundView class]])
            {
                layer.zPosition = 0.5f;
            }
        }
    }
    
    self.extraColorLayer.backgroundColor = barTintColor.CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.extraColorLayer != nil) {
        self.extraColorLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    }
}

@end
