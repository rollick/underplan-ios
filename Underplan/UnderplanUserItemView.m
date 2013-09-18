//
//  UserItemView.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>

#import "UnderplanUserItemView.h"
#import "UnderplanItemDetailsView.h"

#import "UIColor+Underplan.h"

@implementation UnderplanUserItemView

@synthesize detailsView, mainText, contentImage;

- (void)initView
{
    [super initView];
    
    if (VIEW_BORDER_SIZE) {
        self.layer.borderColor = [UIColor underplanBgColor].CGColor;
        self.layer.borderWidth = VIEW_BORDER_SIZE;
    }
    
//    self.backgroundColor = [UIColor purpleColor];
    
    self.detailsView = [[UnderplanItemDetailsView alloc] init];

    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:detailsView];
    
    self.mainText = [[UITextView alloc] init];
    self.mainText.userInteractionEnabled = NO;
    self.mainText.scrollEnabled = NO;
    self.mainText.contentMode = UIViewContentModeTop;
    self.mainText.contentInset = UIEdgeInsetsMake(-8,-4,-4,-4);

//    self.mainText.backgroundColor = [UIColor purpleColor];

    [self.mainText setFont:[UIFont fontWithName:@"Roboto-Light" size:14]];
    [self.mainText setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:mainText];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:detailsView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:52]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(16)-[detailsView]-(16)-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[mainText]-16-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil
                                                                   views:viewsDictionary]];
    
//    format = @"V:|-(16)-[detailsView]-(16)-[mainText]-(16)-|";
//    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:viewsDictionary];
//    
//    [self addConstraints:constraintsArray];
}

@end
