//
//  StoryItemView.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanStoryView.h"
#import "BannerView.h"

#import "UIColor+Underplan.h"

@implementation UnderplanStoryView

- (id)initWithStyle:(StoryStyle)aStyle
{
    style = aStyle;
    return [super init];
}

- (void) initView
{
    [super initView];
    
    NSDictionary *viewsDictionary;
    NSString *format;
    
    self.banner = [[BannerView alloc] init];
    [self.banner setBannerBorder:0];
    [self.banner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.banner];

    self.title = [[UILabel alloc] init];
    NSNumber *titleHeight = @18;
    self.title.font = [UIFont fontWithName:@"OpenSans-Regular" size:[titleHeight integerValue]];
    self.title.text = @"          ......";
    self.title.textColor = [UIColor underplanPrimaryColor];
    [self.title setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.title];
    
    if (style == StoryStyleShort)
    {
        NSNumber *continueHeight = @14;
        self.continueLabel = [[UILabel alloc] init];
        self.continueLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:[continueHeight integerValue]];
        self.continueLabel.text = @"Continue reading →";
        self.continueLabel.textColor = [UIColor underplanPrimaryColor];
        [self.continueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:self.continueLabel];

        viewsDictionary = @{@"mainText": self.mainText,
                            @"detailsView": self.detailsView,
                            @"banner": self.banner,
                            @"title": self.title,
                            @"continueLabel": self.continueLabel};
        
        format = @"V:|-16-[detailsView]-18-[title(titleHeight)]-6-[mainText]-(-6)-[continueLabel]-(>=16)-|";
    }
    else
    {
        viewsDictionary = @{@"mainText": self.mainText,
                            @"detailsView": self.detailsView,
                            @"banner": self.banner,
                            @"title": self.title};
        
        format = @"V:|-16-[detailsView]-16-[title(titleHeight)]-5-[mainText]-(>=16)-|";
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:@{@"titleHeight": titleHeight}
                                                                   views:viewsDictionary]];
    
    format = @"|-16-[title]-16-|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:@{@"title": self.title}]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int bannerWidth = 50;
    int bannerHeight = 28;
    int bannerOffset = 8;
    
    CGRect bannerRect = CGRectMake(self.frame.size.width - bannerWidth, bannerOffset, bannerWidth, bannerHeight);
    
    [self.banner setFrame:bannerRect];
}

@end
