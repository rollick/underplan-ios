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
    
    [self addSubview:_image];
    
    _title = [[UILabel alloc] init];
    [_subTitle setFont:[UIFont fontWithName:@"Roboto-Medium" size:14]];
    [_title setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_title];

    _subTitle = [[UILabel alloc] init];
    [_subTitle setFont:[UIFont fontWithName:@"Roboto-Light" size:12]];
    [_subTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    _subTitle.textColor = [UIColor grayColor];

    [self addSubview:_subTitle];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_image, _subTitle, _title);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_image(52)]-8-[_title]-0-|"
                                                                 options:NSLayoutFormatDirectionLeftToRight metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[_title(30)]-(0)-[_subTitle(18)]-(4)-|"
                                                                 options:NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight
                                                                 metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[_image(52)]-(0)-|"
                                                                 options:NSLayoutFormatAlignAllTop
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
}

@end
