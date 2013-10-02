//
//  UnderplanActivityView.m
//  Underplan
//
//  Created by Mark Gallop on 2/10/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanActivityView.h"
#import "UnderplanViewConstants.h"

#import "UIColor+Underplan.h"

@implementation UnderplanActivityView

- (id)initWithStyle:(UnderplanActivityViewStyle)aStyle
{
    style = aStyle;
    self = [super init];
    
    return self;
}

- (void)initView
{
    [super initView];
    
    NSString *format;
    NSDictionary *viewsDictionary;
    NSDictionary *metrics = @{@"titleHeight": @18,
                              @"padding": @STANDARD_PADDING,
                              @"smallPadding": @6};
    
    if (style == StoryStyleShort || style == StoryStyleShortWithImage || style == StoryStyleLong)
    {
        [self addBannerView];
        [self addTitleLabel];
        
        if (style == StoryStyleShortWithImage)
        {
            [self addContentImage];
            [self addContinueLabel];
        
            // Now setup the vertical constraints
            viewsDictionary = @{@"mainText": self.mainText,
                                @"detailsView": self.detailsView,
                                @"title": self.title,
                                @"contentImage": self.contentImage,
                                @"continueLabel": self.continueLabel};
            
            format = @"V:|-(padding)-[detailsView]-(padding)-[title(titleHeight)]-6-[mainText]-(6)-[continueLabel]-(padding)-|";
        }
        else if (style == StoryStyleShort)
        {
            [self addContinueLabel];
            
            // Now setup the vertical constraints
            viewsDictionary = @{@"mainText": self.mainText,
                                @"detailsView": self.detailsView,
                                @"title": self.title,
                                @"continueLabel": self.continueLabel};
            
            format = @"V:|-(padding)-[detailsView]-(padding)-[title(titleHeight)]-(smallPadding)-[mainText]-(6)-[continueLabel]-(padding)-|";
        }
        else // style == StoryStyleLong
        {
            // Now setup the vertical constraints
            viewsDictionary = @{@"mainText": self.mainText,
                                @"detailsView": self.detailsView,
                                @"title": self.title};
            
            format = @"V:|-(padding)-[detailsView]-(padding)-[title(titleHeight)]-(smallPadding)-[mainText]-(padding)-|";
            
        }
    }
    else if (style == ShortStyleWithImage || style == ShortStyle)
    {
        
        if (style == ShortStyleWithImage)
        {
            [self addContentImage];
            
            viewsDictionary = @{@"mainText": self.mainText,
                                @"detailsView": self.detailsView,
                                @"contentImage": self.contentImage};
            
            format = @"V:|-(padding)-[detailsView(52)]-(padding)-[mainText]-(padding)-[contentImage(150)]-(0)-|";
        }
        else // style == ShortStyle
        {
            viewsDictionary = @{@"mainText": self.mainText,
                                @"detailsView": self.detailsView};
            
            format = @"V:|-(padding)-[detailsView(52)]-(padding)-[mainText]-(padding)-|";
        }
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewsDictionary]];
}

#pragma mark - Standard Subviews

- (void)addBannerView
{
    self.banner = [[UnderplanBannerView alloc] init];
    [self.banner setBannerBorder:0];
    [self.banner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.banner];
}

- (void)addContentImage
{
    self.contentImage = [[UIImageView alloc] init];
    [self.contentImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImage.clipsToBounds = YES;
    
    [self addSubview:self.contentImage];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[contentImage]-0-|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:@{@"contentImage": self.contentImage}]];
}

- (void)addContinueLabel
{
    NSNumber *continueHeight = @14;
    self.continueLabel = [[UILabel alloc] init];
    self.continueLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:[continueHeight integerValue]];
    self.continueLabel.text = @"Continue reading →";
    self.continueLabel.textColor = [UIColor underplanPrimaryColor];
    [self.continueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.continueLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[continueLabel]-(padding)-|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:@{@"padding": @STANDARD_PADDING}
                                                                   views:@{@"continueLabel": self.continueLabel}]];
}

- (void)addTitleLabel
{
    self.title = [[UILabel alloc] init];
    NSNumber *titleHeight = @18;
    self.title.font = [UIFont fontWithName:@"OpenSans-Regular" size:[titleHeight integerValue]];
    self.title.textColor = [UIColor underplanPrimaryColor];
    [self.title setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.title];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[title]-(padding)-|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:@{@"padding": @STANDARD_PADDING}
                                                                   views:@{@"title": self.title}]];
}

#pragma mark - Layout Subviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.banner)
    {
        int bannerWidth = 50;
        int bannerHeight = 28;
        int bannerOffset = 8;
        
        CGRect bannerRect = CGRectMake(self.frame.size.width - bannerWidth, bannerOffset, bannerWidth, bannerHeight);
        
        [self.banner setFrame:bannerRect];
    }
}

@end
