//
//  UIViewController+UnderplanApiNotifications.m
//  Underplan
//
//  Created by Mark Gallop on 25/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <objc/runtime.h>

#import "UIViewController+UnderplanApiNotifications.h"

@implementation UIViewController (UnderplanApiNotifications)

// Standard Meteor Subscriptions. 
- (void)configureStandardApiNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"changed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"removed"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"connected"
                                               object:nil];
}

- (void)clearApiNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    // Override this method to handle notications from Meteor
}

@end
