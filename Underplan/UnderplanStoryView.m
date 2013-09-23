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
    if (self = [super init])
    {
        style = aStyle;

        [self initView];
    }
    
    return self;
}

- (void) initView
{
    [super initView];
    
    NSDictionary *viewsDictionary;
    NSString *format;
    
    UITextView *mainText = self.mainText;
    UnderplanItemDetailsView *detailsView = self.detailsView;
    
    self.banner = [[BannerView alloc] init];
    [self.banner setBannerBorder:0];
    [self.banner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_banner];

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

        viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView, _banner, _title, _continueLabel);
        format = @"V:|-16-[detailsView]-18-[_title(titleHeight)]-6-[mainText]-[_continueLabel]-(>=16)-|";
    }
    else
    {
        viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView, _banner, _title);
        format = @"V:|-16-[detailsView]-16-[_title(titleHeight)]-5-[mainText]-(>=16)-|";
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:@{@"titleHeight": titleHeight}
                                                                   views:viewsDictionary]];
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
