//
//  UnderplanSlideshowControllerViewController.h
//  Underplan
//
//  Created by Mark Gallop on 10/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderplanSlideshowController : UIViewController <UIGestureRecognizerDelegate>
{
    CGFloat _lastScale;
	CGFloat _lastRotation;
	CGFloat _firstX;
	CGFloat _firstY;
    
    CAShapeLayer *_marque;
    NSNumber *_photoIndex;
}

@property (retain, nonatomic) UIImageView *photoImage;
@property (retain, nonatomic) UIView *canvas;
@property (assign) id delegate;

- (id)initWithDelegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate index:(NSNumber *)aIndex;

@end
