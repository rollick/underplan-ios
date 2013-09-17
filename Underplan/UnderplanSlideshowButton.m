//
//  UnderplanSlideshowButton.m
//  Underplan
//
//  Created by Mark Gallop on 16/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanSlideshowButton.h"
#import "UnderplanSlideshowActionDelegate.h"

#import "UIColor+Underplan.h"

#import "UIImage+ImageEffects.h"

@interface UnderplanSlideshowButton ()

@property (assign, nonatomic) SlideshowDirection direction;

@end

@implementation UnderplanSlideshowButton
{
    int padding;
}

@synthesize direction = _direction;

- (id)initWithDelegate:(id <UnderplanSlideshowActionDelegate>)aDelegate andDirection:(SlideshowDirection)aDirection
{
    _direction = aDirection;
    _delegate = aDelegate;
    
    UIImage *image;
    CGRect frame;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    padding = -10;
    
    if (_direction == SlideshowDirectionLeft) {
        image = [UIImage imageNamed:@"chevron-white-left-large.png"];
        frame = CGRectMake(padding, screenRect.size.height / 2 - image.size.height / 2, image.size.width, image.size.height);
    } else {
        image = [UIImage imageNamed:@"chevron-white-right-large.png"];
        frame = CGRectMake(screenRect.size.width - image.size.width - padding, screenRect.size.height / 2 - image.size.height / 2, image.size.width, image.size.height);
    }
    
    self = [self initWithFrame:frame];

    self.layer.backgroundColor = [UIColor underplanBgColor].CGColor;
    [image applyExtraLightEffect];
    self.image = image;
//    self.tintColor = [UIColor underplanPrimaryColor];
    self.opaque = NO;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    // Make it invisible for now
    self.alpha = 0.8f;
    self.contentMode = UIViewContentModeScaleToFill;
    self.clipsToBounds = NO;
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];

    [self addGestureRecognizer:tapRecognizer];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)tapped:(id)sender {
    if (_direction == SlideshowDirectionLeft) {
        [_delegate loadPreviousImage];
    }
    else {
        [_delegate loadNextImage];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)slideOut
{
    int offset;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (_direction == SlideshowDirectionLeft) {
        offset = padding;
    } else {
        offset = screenRect.size.width - self.frame.size.width - padding;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setFrame:CGRectMake(offset, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    }];
}

- (void)slideIn
{
    int offset;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (_direction == SlideshowDirectionLeft) {
        offset = -self.frame.size.width;
    } else {
        offset = screenRect.size.width + self.frame.size.width;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setFrame:CGRectMake(offset, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    }];
}

@end
