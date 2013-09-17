//
//  ActivityTabBarController.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityTabBarController.h"
#import "CommentsViewController.h"
#import "GalleryViewController.h"

#import "SharedApiClient.h"

#import "Activity.h"

@interface ActivityTabBarController ()

@property (retain, nonatomic) CommentsViewController *commentsController;

@end

@implementation ActivityTabBarController

@synthesize activity = _activity, group = _group, comments = _comments;

- (void)configureApiSubscriptions
{
    // Get the full activity data
    NSArray *params = @[_activity.remoteId];
    [[SharedApiClient getClient] addSubscription:@"activityShow" withParameters:params];
    [[SharedApiClient getClient] addSubscription:@"activityCommentsCount" withParameters:params];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveApiUpdate:)
                                                     name:@"activityCommentsCount_ready"
                                                   object:nil];
        
        for (id controller in [self viewControllers]) {
            if ([controller isKindOfClass:[CommentsViewController class]])
            {
                _commentsController = controller;
            }
        }
    }
    return self;
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    [super didReceiveApiUpdate:notification];
    
    // Comment count updated
    NSString *_id = notification.userInfo[@"activityId"];
    if ([_id isEqualToString:_activity.remoteId])
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(activityId like %@)", _id];
        _comments = [[SharedApiClient getClient].collections[@"comments"] filteredArrayUsingPredicate:pred];
        
        [self updateBadgeCount:_commentsController count:[_comments count]];
    }
}

- (void)activityWasSet
{
    [super activityWasSet];
    
    if ([_activity.type isEqualToString:@"short"])
    {
        for (id controller in [self viewControllers])
        {
            if([controller isKindOfClass:[GalleryViewController class]])
            {
                UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:[self.viewControllers indexOfObject:controller]];
                
                [tabBarItem setEnabled:NO];
            }
        }
    }
}

@end
