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
    
    NSString *_id = notification.userInfo[@"_id"];
    if ([_id isEqualToString:_activity.remoteId])
    {
        // Reload the activity to get the new data
        [_activity reload];
        
        // FIXME: Yikes. I don't think pushing changes here to child controllers
        //        is standard practice. We should be observing a property on this
        //        controller from child controllers. AND the child controller should
        //        be deciding for itself what to do when the activity changes, eg a
        //        friendly notice to the user to click 'refresh' to see the changes.
        for (id controller in [self viewControllers])
        {
            if ([controller respondsToSelector:@selector(setActivity:)])
                [controller setActivity:_activity];
        }
    }
    
    // Comment count updated
    _id = notification.userInfo[@"activityId"];
    if ([_id isEqualToString:_activity.remoteId])
    {
        // Set count badge for comments tabbaritem
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
