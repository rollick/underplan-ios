//
//  CommentsViewController.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "CommentsViewController.h"
#import "SharedApiClient.h"
#import "UnderplanBasicLabel.h"

#import "UnderplanCommentItemCell.h"
#import "UIViewController+UnderplanApiNotifications.h"

#import "User.h"
#import "Comment.h"
#import "Activity.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Underplan.h"

@interface CommentsViewController ()

@property (strong, nonatomic) NSArray *comments;
@property (assign, nonatomic) Activity *activity;

@end

@implementation CommentsViewController

@synthesize tableView = _tableView;

- (void)configureApiSubscriptions
{
    // Get the full activity data
    NSArray *params = @[_activity.remoteId];
    [[SharedApiClient getClient] addSubscription:@"activityComments" withParameters:params];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self addObserver:self
               forKeyPath:@"activity"
                  options:(NSKeyValueObservingOptionNew |
                           NSKeyValueObservingOptionOld)
                  context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveApiUpdate:)
                                                     name:@"activityComments_ready"
                                                   object:nil];
    }
    
    return self;
}

- (id)initWithDelegate:(id <UnderplanGroupAwareDelegate>)aDelegate
{
    if (self = [super init])
    {
        _delegate = aDelegate;
        _activity = [_delegate currentActivity];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    if (_delegate)
    {
        _activity = [_delegate currentActivity];
        [self setCommentsByActivityId:_activity.remoteId];
    }
    
    int statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    int navHeight = self.navigationController.navigationBar.frame.size.height;
    int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [self.tableView setContentInset:UIEdgeInsetsMake(navHeight + statusHeight, 0, tabBarHeight, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = @"Comments";
    [self configureApiSubscriptions];

    [self.tableView registerClass:[UnderplanCommentItemCell class] forCellReuseIdentifier:@"Comment"];
}

#pragma mark - API handling

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    if ([keyPath isEqual:@"activity"] && _activity)
    {
        [self configureApiSubscriptions];
    }
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    // Comment count updated
    NSString *_id = notification.userInfo[@"activityId"];
    if ([_id isEqualToString:_activity.remoteId])
    {
        [self setCommentsByActivityId:_id];
    }
}

- (void)setCommentsByActivityId:(NSString *)activityId
{
    dispatch_queue_t commentsQueue = dispatch_queue_create("Comments Processing Queue", NULL);
    dispatch_async(commentsQueue, ^{
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(activityId like %@)", activityId];
        
        // Filter for comments related to the current activity
        NSArray *filteredList = [[SharedApiClient getClient].collections[@"comments"] filteredArrayUsingPredicate:pred];
        
        // Sort by oldest to newest
        _comments = [filteredList sortedArrayUsingComparator: ^(id a, id b)
        {
            NSString *first;
            NSString *second;
            // FIXME:   Hack! There is some data on the server which hasn't been converted
            //          to a date correctly. It is a string like "2012-11-10T08:21:59". It
            //          is still good for sorting. Same hack used in activity feed controller
            if ([[a objectForKey:@"created"] isKindOfClass:[NSString class]])
            {
                first = [a objectForKey:@"created"];
                second = [b objectForKey:@"created"];
            }
            else
            {
                first = [[a objectForKey:@"created"] objectForKey:@"$date"];
                second = [[b objectForKey:@"created"] objectForKey:@"$date"];
            }
            
            return [first compare:second];
        }];
        
        // perform UI updates in the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate updateBadgeCount:self count:[_comments count]];
            
            if ([_comments count] > 0)
                [UnderplanBasicLabel removeFrom:self.view];
            else
                [UnderplanBasicLabel addTo:self.view text:@"No Comments"];
            
            [self.tableView reloadData];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc
{
    self.tableView.delegate = nil;
    
    self.delegate = nil;
    [self removeObserver:self forKeyPath:@"activity"];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *_comment = _comments[indexPath.row];
    
    Comment *comment = [[Comment alloc] initWithId:_comment[@"_id"]];

    UnderplanCommentItemCell *cell = [[UnderplanCommentItemCell alloc] init];
    return [cell cellHeight:comment.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnderplanCommentItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Comment" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *_comment = _comments[indexPath.row];
    
    Comment *comment = [[Comment alloc] initWithId:_comment[@"_id"]];
    [cell loadComment:comment];
    
    self.tableView.backgroundColor = [UIColor underplanBgColor];
    
    return cell;
}

@end
