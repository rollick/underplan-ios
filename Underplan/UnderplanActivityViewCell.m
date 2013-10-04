//
//  UnderplanActivityViewCell.m
//  Underplan
//
//  Created by Mark Gallop on 2/10/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanActivityViewCell.h"
#import "UnderplanActivityView.h"

#import "UIColor+Underplan.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanActivityViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ([reuseIdentifier isEqualToString:@"ShortWithImage"])
        _style = ShortStyleWithImage;
    
    else if ([reuseIdentifier isEqualToString:@"Short"])
        _style = ShortStyle;
    
    else if ([reuseIdentifier isEqualToString:@"StoryWithImage"])
        _style = StoryStyleShortWithImage;
    
    else if ([reuseIdentifier isEqualToString:@"Story"])
        _style = StoryStyleShort;
    
    self.mainView = [[UnderplanActivityView alloc] initWithStyle:_style];
    self.mainView.backgroundColor = [UIColor underplanCellBgColor];
    [self.mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.containerView addSubview:self.mainView];
    
    NSDictionary *viewsDictionary = @{@"mainView": self.mainView};
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllLeft
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    
    return self;
}

- (void)initView
{
    [super initView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)loadActivityImage:(UIImage *)image
{
    [self.mainView.contentImage setImage:image];
}

- (void)clearActivityImage
{
    self.mainView.contentImage = nil;
}

@end
