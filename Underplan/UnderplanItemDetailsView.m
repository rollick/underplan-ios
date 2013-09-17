//
//  ItemDetailsView.m
//  Underplan
//
//  Created by Mark Gallop on 28/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanItemDetailsView.h"

@implementation UnderplanItemDetailsView

@synthesize image, subTitle, title;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

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
    image = [[UIImageView alloc] init];
    [image setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.image.backgroundColor = [UIColor yellowColor];
    
    [self addSubview:image];
    
    title = [[UILabel alloc] init];
    [subTitle setFont:[UIFont fontWithName:@"Helvetica-Light" size:14]];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.title.backgroundColor = [UIColor blueColor];
    
    [self addSubview:title];

    subTitle = [[UILabel alloc] init];
    [subTitle setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [subTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.subTitle.backgroundColor = [UIColor orangeColor];

    [self addSubview:subTitle];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(image, title, subTitle);
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:image
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:52]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:image
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:52]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[image]-8-[title]-0-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:28]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subTitle
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:18]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[title]-(2)-[subTitle]-(2)-|"
                                                                 options:NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight
                                                                 metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[image]-(8)-[title]-|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
}

@end
