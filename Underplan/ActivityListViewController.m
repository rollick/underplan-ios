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
@property NSMutableDictionary *activityIdToImageDownloadOperations;
@property NSOperationQueue *imageLoadingOperationQueue;

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
    
    self.imageLoadingOperationQueue = [[NSOperationQueue alloc] init];
    
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
    
    [self.view addSubview:self.tableView];
    
    // Register cell classes
    [self.tableView registerClass:[UnderplanShortItemCell class] forCellReuseIdentifier:@"Short"];
    [self.tableView registerClass:[UnderplanShortItemCell class] forCellReuseIdentifier:@"ShortWithImage"];
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

// Filter for current group
- (NSArray *)filteredList
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(group like %@)", _group.remoteId];
    
    return [[SharedApiClient getClient].collections[@"activities"] filteredArrayUsingPredicate:pred];
}

// Sort by newest to oldest
- (NSArray *)computedList
{
    return [[self filteredList] sortedArrayUsingComparator: ^(id a, id b) {
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
        if (limit > [[self filteredList] count]) {
            complete = YES;
            [self setLoading:NO];
        }
        else
        {
            complete = NO;
            [self setLoading:NO];
        }
        
        if (!self.loading)
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.imageLoadingOperationQueue cancelAllOperations];
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
        }
        else
        {
            UnderplanShortItemCell *tempCell;
            if ([activity hasTags])
                tempCell = [[UnderplanShortItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShortWithImage"];
            else
                tempCell = [[UnderplanShortItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Short"];
            
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
        UnderplanStoryItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Story"
                                                                       forIndexPath:indexPath];
        [cell loadActivity:activity];
        
        return cell;
    }
    else if ([activity hasTags])
    {
        UnderplanShortItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShortWithImage"
                                                                       forIndexPath:indexPath];
        [cell loadActivity:activity];
        
        //Create a block operation for loading the image into the profile image view
        NSBlockOperation *loadImageIntoCellOp = [[NSBlockOperation alloc] init];
        //Define weak operation so that operation can be referenced from within the block without creating a retain cycle
        __weak NSBlockOperation *weakOp = loadImageIntoCellOp;
        [loadImageIntoCellOp addExecutionBlock:^(void)
        {
            //Some asynchronous work. Once the image is ready, it will load into view on the main queue
            UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:activity.photoUrl]]];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void)
            {
                //Check for cancelation before proceeding. We use cellForRowAtIndexPath to make sure we get nil for a non-visible cell
                if (!weakOp.isCancelled)
                {
                    UnderplanShortItemCell *cell = (UnderplanShortItemCell *)[tableView cellForRowAtIndexPath:indexPath];
                    [cell loadActivityImage:profileImage];
                    [self.activityIdToImageDownloadOperations removeObjectForKey:activity.remoteId];
                }
            }];
        }];
        
        //Save a reference to the operation in an NSMutableDictionary so that it can be cancelled later on
        if (activity.remoteId) {
            [self.activityIdToImageDownloadOperations setObject:loadImageIntoCellOp forKey:activity.remoteId];
        }
        
        //Add the operation to the designated background queue
        if (loadImageIntoCellOp) {
            [self.imageLoadingOperationQueue addOperation:loadImageIntoCellOp];
        }
        
        //Make sure cell doesn't contain any traces of data from reuse -
        //This would be a good place to assign a placeholder image
        cell.mainView.contentImage.image = [UIImage imageNamed:@"placeholder_wide.png"];;
        
        return cell;
    } else {
        UnderplanShortItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Short"
                                                                       forIndexPath:indexPath];
        [cell loadActivity:activity];
        
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

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = self.computedList;

    // If the index of this cell exceeds the row count for the data source then
    // there must have been a refresh of the data before this cell was displayed.
    // => ignore this cell
    if (indexPath.row > [list count])
    {
        NSDictionary *activityData = list[indexPath.row];
        Activity *activity = [[Activity alloc] initWithId:activityData[@"_id"]];

        //Fetch operation that doesn't need executing anymore
        NSBlockOperation *ongoingDownloadOperation = [self.activityIdToImageDownloadOperations objectForKey:activity.remoteId];
        if (ongoingDownloadOperation)
        {
            //Cancel operation and remove from dictionary
            [ongoingDownloadOperation cancel];
            [self.activityIdToImageDownloadOperations removeObjectForKey:activity.remoteId];
        }
    }
    else // clear any ongoing downloads
    {
        for (NSBlockOperation *ongoingDownloadOperation in self.activityIdToImageDownloadOperations) {
            //Cancel operation and remove from dictionary
            [ongoingDownloadOperation cancel];
//            [self.activityIdToImageDownloadOperations removeObjectForKey:activity.remoteId];
        }
    }
}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSArray *visibleCells = [_tableView visibleCells];
//    [visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UnderplanShortItemCell *cell = (UnderplanShortItemCell *)obj;
//        Activity *activity = [[Activity alloc] initWithId:cell.itemId];
//        if ([activity hasTags])
//        {
//            [cell loadActivityImage:activity];
//        }
//    }];
//}

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
