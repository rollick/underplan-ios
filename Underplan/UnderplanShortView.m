//
//  ShortItemView.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanShortView.h"

#import "UIColor+Underplan.h"

@implementation UnderplanShortView

@synthesize contentImage;

- (id)initWithStyle:(ShortStyle)aStyle
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
    
    if (style == ShortStyleWithImage)
    {
        self.contentImage = [[UIImageView alloc] init];
        self.contentImage.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
        self.contentImage.clipsToBounds = YES;
        
        [self addSubview:self.contentImage];
        
        viewsDictionary = @{@"mainText": self.mainText,
                            @"detailsView": self.detailsView,
                            @"contentImage": self.contentImage};
        
        format = @"V:|-(16)-[detailsView]-(16)-[mainText]-(>=0)-[contentImage(150)]-(0)-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                     options:NSLayoutFormatAlignAllLeft
                                                                     metrics:nil
                                                                       views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[contentImage]-0-|"
                                                                     options:NSLayoutFormatAlignAllLeft
                                                                     metrics:nil
                                                                       views:viewsDictionary]];
    }
    else
    {
        viewsDictionary = @{@"mainText": self.mainText,
                            @"detailsView": self.detailsView};
        
        format = @"V:|-(16)-[detailsView]-(16)-[mainText]-(0)-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                     options:NSLayoutFormatAlignAllLeft
                                                                     metrics:nil
                                                                       views:viewsDictionary]];
    }
}

@end
