//
//  UnderplanActivityAwareDelegate.h
//  Underplan
//
//  Created by Mark Gallop on 12/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Activity.h"

@protocol UnderplanActivityAwareDelegate <NSObject>

- (Activity *)currentActivity;
- (NSArray *)currentActivityComments;
- (void)updateCommentsCount:(id)aController count:(NSUInteger)count;

@end
