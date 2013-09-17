//
//  UnderplanSlideshowButton.h
//  Underplan
//
//  Created by Mark Gallop on 16/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UnderplanSlideshowActionDelegate.h"

typedef enum SlideshowDirection {
    SlideshowDirectionLeft,
    SlideshowDirectionRight
} SlideshowDirection;

@interface UnderplanSlideshowButton : UIImageView <UIGestureRecognizerDelegate>

@property (assign, nonatomic) id <UnderplanSlideshowActionDelegate> delegate;

- (id)initWithDelegate:(id <UnderplanSlideshowActionDelegate>)aDelegate andDirection:(SlideshowDirection)aDirection;
- (void)slideIn;
- (void)slideOut;

@end
