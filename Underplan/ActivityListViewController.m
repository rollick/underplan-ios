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
        
        [self addObserver:self
               forKeyPath:@"loading"
                  options:NSKeyValueObservingOptionNew
                  context:ActivityListKVOContext];
    }
    
    return self;
}

-(void)reloadData
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_delegate)
        _group = [_delegate currentGroup];
    
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
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = YES;
    
    // Fix the scrollview being behind tabbar
    if (self.tabBarController) {
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.bottom = self.tabBarController.tabBar.frame.size.height;
        self.tableView.contentInset = inset;
    }
    
    [self.view addSubview:self.tableView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"loading"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:@1]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        }
    }
}

- (NSArray *)computedList {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(group like %@)", self.group.remoteId];

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
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // Register cell classes
    [self.tableView registerClass:[UnderplanShortItemCell class] forCellReuseIdentifier:@"Short"];
    [self.tableView registerClass:[UnderplanStoryItemCell class] forCellReuseIdentifier:@"Story"];
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"feedActivities_ready"])
    {
        if (limit > [self.computedList count]) {
            complete = YES;
        } else
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
    
    if ([activity.type isEqualToString:@"story"]) {
        UnderplanStoryItemCell *tempCell = [[UnderplanStoryItemCell alloc] init];
        return [tempCell cellHeight:activity.summaryText];
    } else
    {
        UnderplanShortItemCell *tempCell = [[UnderplanShortItemCell alloc] init];
        return [tempCell cellHeight:activity.summaryText];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *activityData = self.computedList[indexPath.row];
    Activity *activity = [[Activity alloc] initWithId:activityData[@"_id"]];
    
    UnderplanTableViewCell *cell;
    static NSString *cellIdentifier;
    if ([activity.type isEqualToString:@"story"])
        cellIdentifier = @"Story";
    else
        cellIdentifier = @"Short";

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Fetch owner and id for cell
    cell.itemId = activity.remoteId;
    User *owner = [[User alloc] initWithId:activity.ownerId];

    // Set the owners name as the title
    cell.detailsView.title.text = owner.profile[@"name"];

    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [cell.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }

    cell.detailsView.subTitle.text = [activity summaryInfo];
    cell.mainText.text = activity.summaryText;
    
    // Set the shorty photo if available
    if ([activity.type isEqual:@"short"])
    {
        if (!tableView.decelerating)
        {
            NSString *photoUrl = [activity photoUrl];
            if (photoUrl && ![photoUrl isEqual:@""])
            {
                [cell.contentImage setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            }
        } else {
            // table is scrolling...
            cell.contentImage.image = nil;
        }
    }

    cell.loaded = YES;

    self.view.backgroundColor = [UIColor underplanBgColor];

    return cell;
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
    NSArray *visibleCells = [self.tableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UnderplanTableViewCell *cell = (UnderplanTableViewCell *)obj;
        Activity *activity = [[Activity alloc] initWithId:cell.itemId];
        NSString *photoUrl = [activity photoUrl];
        if (photoUrl && ![photoUrl isEqual:@""])
        {
            [cell.contentImage setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showActivity" sender:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showActivity"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
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
