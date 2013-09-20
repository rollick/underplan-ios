//
//  UnderplanBasicLabel.m
//  Underplan
//
//  Created by Mark Gallop on 19/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanBasicLabel.h"

@implementation UnderplanBasicLabel

+ (id)addTo:(UIView *)aView text:(NSString *)someText
{
    // First remove existing labels
    [self removeFrom:aView];
    
    UnderplanBasicLabel *label = [[self alloc] init];
    label.text = someText;
//    label.frame = CGRectMake(0, 0, 100, 20);

//    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];

    [aView addSubview:label];
    [aView bringSubviewToFront:label];

    [aView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:aView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];

    // Center the button horizontally with the parent view
    [aView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:aView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
//
//    [aView addConstraint:[NSLayoutConstraint constraintWithItem:label
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:NSLayoutAttributeNotAnAttribute
//                                                    multiplier:1
//                                                      constant:100]];
//
//    [aView addConstraint:[NSLayoutConstraint constraintWithItem:label
//                                                      attribute:NSLayoutAttributeWidth
//                                                      relatedBy:NSLayoutRelationEqual
//                                                         toItem:nil
//                                                      attribute:NSLayoutAttributeNotAnAttribute
//                                                     multiplier:1
//                                                       constant:200]];
    
    return label;
}

+ (void)removeFrom:(UIView *)mainView
{
    for (UIView *aView in mainView.subviews) {
		if ([aView isKindOfClass:self]) {
			[aView removeFromSuperview];
		}
	}
}

@end
