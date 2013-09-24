//
//  ActivityListViewController.m
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "ActivityListViewController.h"
#import "UnderplanAppDelegate.h"
#import "ActivityViewController.h"
#import "UnderplanShortItemCell.h"
#import "UnderplanStoryItemCell.h"
#import "UITabBarController+ShowHideTabBar.h"
#import "UIViewController+UnderplanApiNotifications.h"
#import "SharedApiClient.h"
#import "UnderplanBasicLabel.h"

#import "User.h"
#import "Activity.h"
#import "Photo.h"
#import "Group.h"

#import "BSONIdGenerator.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

#import "UIColor+Underplan.h"

@interface ActivityListViewController ()

@property BOOL loading;

@end

@implementation ActivityListViewController {
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
    BOOL complete;
    int limit;
}

static void * const ActivityListKVOContext = (void*)&ActivityListKVOContext;

@synthesize loading = _loading;

#pragma mark - Meteor stuff

- (void)configureApiSubscriptions
{
    if (!limit) {
        limit = 10;
    }
    
    NSArray *params = @[@{@"groupId":_group.remoteId, @"limit":[NSNumber numberWithInt:limit]}];
    [[SharedApiClient getClient] addSubscription:@"feedActivities" withParameters:params];
    
    // Update the user interface for the group.
    _activities = [SharedApiClient getClient].collections[@"activities"];
}

#pragma mark - Managing the activity details

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveApiUpdate:)
                                                     name:@"feedActivities_ready"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveApiUpdate:)
                                                     name:@"activities_removed"
                                                   object:nil];
        
        [self addObserver:self
               forKeyPath:@"loading"
                  options:NSKeyValueObservingOptionNew
                  context:ActivityListKVOContext];

        [self addObserver:self
               forKeyPath:@"group"
                  options:NSKeyValueObservingOptionNew
                  context:ActivityListKVOContext];
    }
    
    return self;
}

-(void)reloadData
{
    if ([self.computedList count] > 0)
        [UnderplanBasicLabel removeFrom:self.view];
    else
        [UnderplanBasicLabel addTo:self.view text:@"No Activities"];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.delegate)
        self.group = [self.delegate currentGroup];
    
    self.view = [[UIView alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.view.backgroundColor = [UIColor underplanBgColor];
    self.tableView.backgroundColor = [UIColor underplanBgColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = YES;
    
    [self.view addSubview:self.tableView];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
    
    
    // Register cell classes
    [self.tableView registerClass:[UnderplanShortItemCell class] forCellReuseIdentifier:@"Short"];
    [self.tableView registerClass:[UnderplanStoryItemCell class] forCellReuseIdentifier:@"Story"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"loading"] && self.tableView)
    {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:@1]) {
            [MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
        } else {
            [MBProgressHUD hideHUDForView:self.tableView animated:NO];
        }
    }
    else if ([keyPath isEqual:@"group"])
    {
        // If new group set then show loadin icon
        if ([change objectForKey:NSKeyValueChangeNewKey])
            [self setLoading:YES];
    }
}

- (NSArray *)computedList {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(group like %@)", _group.remoteId];

    // Filter for current group
    NSArray *filteredList = [[SharedApiClient getClient].collections[@"activities"] filteredArrayUsingPredicate:pred];
    
    // Sort by newest to oldest
    return [filteredList sortedArrayUsingComparator: ^(id a, id b) {
        NSString *first = [[a objectForKey:@"created"] objectForKey:@"$date"];
        NSString *second = [[b objectForKey:@"created"] objectForKey:@"$date"];
        return [second compare:first];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Activities";
    [self configureApiSubscriptions];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    // If the feed subscription is ready or an activity is added/removed/changed for the current group
    if (([[notification name] isEqualToString:@"feedActivities_ready"]) ||
        (
          [[notification userInfo][@"group"] isEqualToString:_group.remoteId] &&
          [@[@"changed", @"added"] containsObject:[notification name]]
        ) ||
        [[notification name] isEqualToString:@"activities_removed"])
    {
        if (limit > [self.computedList count]) {
            complete = YES;
            [self setLoading:NO];
        }
        else
        {
            complete = NO;
            [self setLoading:NO];
        }
        
        if (! _loading)
        {
            [self reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View

-(void)dealloc
{
    self.tableView.delegate = nil;
    
    [self removeObserver:self forKeyPath:@"loading"];
    [self removeObserver:self forKeyPath:@"group"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"numberOfRowsInSection returning %d", [self.computedList count]);
    return [self.computedList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *activityData = self.computedList[indexPath.row];
    Activity *activity = [[Activity alloc] initWithId:activityData[@"_id"]];
    
    // If activity has fully loaded
    if (activity.summaryText)
    {
        if ([activity.type isEqualToString:@"story"]) {
            UnderplanStoryItemCell *tempCell = [[UnderplanStoryItemCell alloc] init];
            return [tempCell cellHeight:activity.summaryText];
        } else
        {
            UnderplanShortItemCell *tempCell = [[UnderplanShortItemCell alloc] init];
            return [tempCell cellHeight:activity.summaryText];
        }
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *activityData = self.computedList[indexPath.row];
    Activity *activity = [[Activity alloc] initWithId:activityData[@"_id"]];

    self.view.backgroundColor = [UIColor underplanBgColor];
    
    if ([activity.type isEqualToString:@"story"])
    {
        UnderplanStoryItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Story" forIndexPath:indexPath];
        [cell loadActivity:activity];
        
        return cell;
    }
    else
    {
        UnderplanShortItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Short" forIndexPath:indexPath];
        [cell loadActivity:activity];
        
        if (!tableView.decelerating)
        {
            [cell loadActivityImage:activity];
        }
        else
        {
            [cell clearActivityImage];
        }
        
        return cell;
    }

    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If last section is about to be shown...
    if(scrollView.contentOffset.y < 0){
        //it means table view is pulled down like refresh
        //NSLog(@"refresh!");
    }
    else if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height))
    {
        if (! _loading && ! complete )
        {
            [self setLoading:YES];
            limit = limit + 10;
            
            NSArray *params = @[@{@"groupId":_group.remoteId, @"limit":[NSNumber numberWithInt:limit]}];
            [[SharedApiClient getClient] addSubscription:@"feedActivities" withParameters:params];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [_tableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UnderplanTableViewCell *cell = (UnderplanTableViewCell *)obj;
        Activity *activity = [[Activity alloc] initWithId:cell.itemId];
        [cell loadActivityImage:activity];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showActivity" sender:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showActivity"]) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        NSDictionary *object = self.computedList[indexPath.row];

        id controller = [segue destinationViewController];
        if ([controller respondsToSelector:@selector(activityId)]) {
            [controller setValue:object[@"_id"] forKey:@"activityId"];
        }
        if ([controller respondsToSelector:@selector(group)]) {
            [controller setValue:_group forKey:@"group"];
        }
    }
}

@end
