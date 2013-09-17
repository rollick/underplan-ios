//
//  UnderplanSlideshowActionDelegate.h
//  Underplan
//
//  Created by Mark Gallop on 16/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Photo.h"

@protocol UnderplanSlideshowActionDelegate <NSObject>

- (void)loadNextImage;
- (void)loadPreviousImage;

@end
