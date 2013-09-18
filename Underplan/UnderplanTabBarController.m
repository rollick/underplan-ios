//
//  UnderplanTabBarControllerViewController.m
//  Underplan
//
//  Created by Mark Gallop on 14/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTabBarController.h"
#import "UIViewController+UnderplanApiNotifications.h"
#import "UIViewController+ShowHideBars.h"

@interface UnderplanTabBarController ()

@end

@implementation UnderplanTabBarController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self addObserver:self
               forKeyPath:@"activityId"
                  options:(NSKeyValueObservingOptionNew |
                           NSKeyValueObservingOptionOld)
                  context:NULL];
        
        [self addObserver:self
               forKeyPath:@"groupId"
                  options:(NSKeyValueObservingOptionNew |
                           NSKeyValueObservingOptionOld)
                  context:NULL];
        
        for (int i = 0; i < [self.viewControllers count]; i++)
        {
            UIViewController* controller = [self.viewControllers objectAtIndex:i];
            
            if ([controller respondsToSelector:@selector(delegate)]) {
                [controller setValue:self forKey:@"delegate"];
            }
            
            if ([tabBarImageNames count])
            {
                UIImage *selectedImage = [UIImage imageNamed:tabBarImageNames[i][@"selected"]];
                UIImage *unselectedImage = [UIImage imageNamed:tabBarImageNames[i][@"unselected"]];
                
                if ([controller.tabBarItem respondsToSelector:@selector(selectedImage)])
                {
                    [controller.tabBarItem setSelectedImage:selectedImage];
                    [controller.tabBarItem setImage:unselectedImage];
                }
                else
                {
                    [controller.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
                }
            }
        }
        
        // Example observers
//        [self addObserver:self
//               forKeyPath:@"activityId"
//                  options:(NSKeyValueObservingOptionNew |
//                           NSKeyValueObservingOptionOld)
//                  context:NULL];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(didReceiveApiUpdate:)
//                                                     name:@"activityCommentsCount_ready"
//                                                   object:nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self showBars];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure api notifications manually as this class
    // isn't extending the UnderplanViewController class
    [self configureStandardApiNotifications];
    
    [self configureApiSubscriptions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"activityId"];
    [self removeObserver:self forKeyPath:@"groupId"];
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"activityId"]) {
        self.activity = [[Activity alloc] initWithId:[change objectForKey:NSKeyValueChangeNewKey]];
        self.group = _activity.group;
        [self activityWasSet];
    } else if ([keyPath isEqual:@"groupId"]) {
        self.group = [[Group alloc] initWithId:[change objectForKey:NSKeyValueChangeNewKey]];
    }
}

- (void)activityWasSet
{
    // Override in subclass
}

#pragma mark - UnderplanGroupAwareDelegate methods

- (Group *)currentGroup
{
    return self.group;
}

- (Activity *)currentActivity
{
    return self.activity;
}

- (NSArray *)currentActivityComments
{
    return self.comments;
}

- (void)updateBadgeCount:(id)aController count:(NSUInteger)count
{
    // Set the badge count
    if (count)
        [self setBadgeValue:[NSString stringWithFormat: @"%d", count] onController:aController];
}

- (void)setBadgeValue:(NSString *)value onController:(id)controller
{
    UITabBarItem *tabbar = [self.tabBar.items objectAtIndex:[self.viewControllers indexOfObject:controller]];
    
    [tabbar setBadgeValue:value];
}

#pragma mark - Underplan Group / Activity variables

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

#pragma mark - Meteor Subscriptions and Notifications

- (void)configureApiSubscriptions
{
    // Override in subclass
}

#pragma mark - Nav Bar Actions

- (void)addNavBarAction:(NSString *)imageName aController:(UIViewController *)aController actionSelector:(SEL)actionSelector
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:aController action:actionSelector];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)clearNavBarActions
{
    self.navigationItem.rightBarButtonItems = @[];
}

@end
