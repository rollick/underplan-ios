//
//  StoryItemView.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanStoryView.h"
#import "BannerView.h"

#import <UIColor+HexString.h>

@implementation UnderplanStoryView

@synthesize banner;

- (void) initView
{
    [super initView];
    
    UITextView *mainText = self.mainText;
    UnderplanItemDetailsView *detailsView = self.detailsView;
    
    self.banner = [[BannerView alloc] init];
    [self.banner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.banner];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView, banner);
    
    NSString *format = @"V:|-16-[detailsView]-16-[mainText]-(>=16)-|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int bannerWidth = 50;
    int bannerHeight = 28;
    int bannerOffset = 8;
    
    CGRect bannerRect = CGRectMake(self.frame.size.width - bannerWidth - CELL_BORDER_SIZE, bannerOffset + CELL_BORDER_SIZE, bannerWidth, bannerHeight);
    
    [self.banner setFrame:bannerRect];
}

@end
