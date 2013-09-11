//
//  ActivityTabBarController.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityTabBarController.h"
#import "CommentsViewController.h"

#import "UIViewController+UnderplanApiNotifications.h"
#import "SharedApiClient.h"

#import "Activity.h"

@interface ActivityTabBarController ()

@property (retain, nonatomic) CommentsViewController *commentsController;

@end

@implementation ActivityTabBarController

@synthesize activity = _activity, group = _group;

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
        [self addObserver:self
               forKeyPath:@"activityId"
                  options:(NSKeyValueObservingOptionNew |
                           NSKeyValueObservingOptionOld)
                  context:NULL];
        
        for (id controller in [self viewControllers]) {
            if ([controller isKindOfClass:[CommentsViewController class]])
            {
                _commentsController = controller;
            }
            
            if ([controller respondsToSelector:@selector(delegate)]) {
                [controller setValue:self forKey:@"delegate"];
            }

            [self addObserver:controller
                   forKeyPath:@"comments"
                      options:(NSKeyValueObservingOptionNew |
                               NSKeyValueObservingOptionOld)
                      context:NULL];
            
            [self addObserver:controller
                   forKeyPath:@"activity"
                      options:(NSKeyValueObservingOptionNew |
                               NSKeyValueObservingOptionOld)
                      context:NULL];
            
            [self addObserver:controller
                   forKeyPath:@"group"
                      options:(NSKeyValueObservingOptionNew |
                               NSKeyValueObservingOptionOld)
                      context:NULL];
        }
    }
    return self;
}

- (void)setBadgeValue:(NSString *)value onController:(id)controller
{
    UITabBarItem *tabbar = [self.tabBar.items objectAtIndex:[self.viewControllers indexOfObject:controller]];
    
    [tabbar setBadgeValue:value];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure api notifications manually as this class
    // isn't extending the UnderplanViewController class
    [self configureApiNotifications];
    
    [self configureApiSubscriptions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"activityId"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    // Refresh view if this activity was updated
    if (![[notification name] isEqualToString:@"ready"] && notification.userInfo[@"_id"] == _activity.remoteId) {
//        [self setActivityDetails];
    }
    
    // Comment count updated
    NSString *_id = notification.userInfo[@"activityId"];
    if ([_id isEqualToString:_activity.remoteId])
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(activityId like %@)", _id];
        _comments = [[SharedApiClient getClient].collections[@"comments"] filteredArrayUsingPredicate:pred];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"activityId"]) {
        [self setActivity:[[Activity alloc] initWithId:[change objectForKey:NSKeyValueChangeNewKey]]];
    }
}

- (void)setActivityId:(id)newActivityId
{
    if (_activityId != newActivityId) {
        _activityId = newActivityId;
    }
}

- (void)setGroupId:(id)newGroupId
{
    if (_groupId != newGroupId) {
        _groupId = newGroupId;
    }
}

#pragma mark - Tab Bar Controller
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == _commentsController) {
        NSArray *params = @[_activity.remoteId];
        [[SharedApiClient getClient] addSubscription:@"activityComments" withParameters:params];
    }
    return YES;
}

#pragma mark - Comments Tab

- (void)updateCommentsCount
{
    if (_commentsController)
    {
        // Set the badge count
        [self setBadgeValue:[NSString stringWithFormat: @"%d", [_comments count]] onController:_commentsController];
    }
}

@end
