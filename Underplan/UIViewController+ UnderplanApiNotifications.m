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

- (void)configureApiNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"removed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"ready"
                                               object:nil];
}

- (void)clearApiNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

//- (void)didReceiveApiUpdate:(NSNotification *)notification
//{
//    // Override this method to handle notications from Meteor
//    if ([[notification name] isEqualToString:@"ready"])
//    {
//        NSLog(@"Meteor ready...");
//    }
//}

@end
