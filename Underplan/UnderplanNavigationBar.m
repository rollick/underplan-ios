//
//  UnderplanNavigationBar.m
//  Underplan
//
//  Created by Mark Gallop on 20/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanNavigationBar.h"

#import "UnderplanBarBackgroundView.h"

@interface UnderplanNavigationBar ()

@property (nonatomic, strong) CALayer *extraColorLayer;

@end

static CGFloat const kDefaultColorLayerOpacity = 0.7f;
static CGFloat const kSpaceToCoverStatusBars = 100.0f;
static NSString *layerName = @"Navigation BG Layer";

@implementation UnderplanNavigationBar

- (void)setBarTintColor:(UIColor *)barTintColor
{
    [super setBarTintColor:barTintColor];
    if (self.extraColorLayer == nil) {
        UnderplanBarBackgroundView *colourView = [[UnderplanBarBackgroundView alloc] init];
        colourView.opaque = NO;
        colourView.alpha = .7f;
        colourView.backgroundColor = barTintColor;
        colourView.layer.name = layerName;
        
        self.extraColorLayer = colourView.layer;
//        self.extraColorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer insertSublayer:self.extraColorLayer atIndex:1];
    }
    else
    {
        // Ensure the BG layer is at the back
        for (CALayer *layer in self.layer.sublayers)
        {
            if ([layer.name isEqualToString:layerName])
            {
                layer.zPosition = -1.0f;
            }
        }
    }
    self.extraColorLayer.backgroundColor = barTintColor.CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.extraColorLayer != nil) {
        self.extraColorLayer.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
    }
}

@end
