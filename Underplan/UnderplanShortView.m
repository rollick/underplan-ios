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

- (void)initView
{
    [super initView];
        
    self.contentImage = [[UIImageView alloc] init];
    self.contentImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImage.clipsToBounds = YES;
    [self addSubview:self.contentImage];
    
    UITextView *mainText = self.mainText;
    UnderplanItemDetailsView *detailsView = self.detailsView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView, contentImage);
    
    NSString *format = @"V:|-16-[detailsView]-16-[mainText]-(>=0)-[contentImage]-0-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];

    [self addConstraints:constraintsArray];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.contentImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:150];
    
    [self addConstraint:constraint];
    
    format = @"|-0-[contentImage]-0-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self addConstraints:constraintsArray];
}

@end
