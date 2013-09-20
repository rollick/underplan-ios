//
//  ItemDetailsView.m
//  Underplan
//
//  Created by Mark Gallop on 28/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanItemDetailsView.h"

@implementation UnderplanItemDetailsView

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
    _image = [[UIImageView alloc] init];
    [_image setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.image.backgroundColor = [UIColor yellowColor];
    
    [self addSubview:_image];
    
    _title = [[UILabel alloc] init];
    [_subTitle setFont:[UIFont fontWithName:@"Roboto-Medium" size:14]];
    [_title setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.title.backgroundColor = [UIColor blueColor];
    
    [self addSubview:_title];

    _subTitle = [[UILabel alloc] init];
    [_subTitle setFont:[UIFont fontWithName:@"Roboto-Light" size:12]];
    [_subTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    _subTitle.textColor = [UIColor grayColor];

    [self addSubview:_subTitle];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_image, _subTitle, _title);
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_image
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:52]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_image
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:52]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_image]-8-[_title]-0-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_title
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:28]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_subTitle
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:18]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[_title]-(2)-[_subTitle]-(2)-|"
                                                                 options:NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight
                                                                 metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_image]-(8)-[_title]-|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
}

@end
