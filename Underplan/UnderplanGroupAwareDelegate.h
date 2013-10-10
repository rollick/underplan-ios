//
//  UnderplanGroupAwareDelegate.h
//  Underplan
//
//  Created by Mark Gallop on 12/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Group.h"
#import "Activity.h"

@protocol UnderplanGroupAwareDelegate <NSObject>

@property (strong, nonatomic) Activity *activity;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSArray *comments;

- (Group *)currentGroup;
- (Activity *)currentActivity;
- (NSArray *)currentActivityComments;
- (void)updateBadgeCount:(id)aController count:(NSUInteger)count;

@end
