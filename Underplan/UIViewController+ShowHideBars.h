//
//  UIViewController+ShowHideBars.h
//  Underplan
//
//  Created by Mark Gallop on 16/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShowHideBars)

@property (nonatomic, retain) id timer;

- (void)showBarsTemporarily;
- (void)showBars;
- (void)hideBars;

@end
