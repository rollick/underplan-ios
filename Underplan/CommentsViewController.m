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
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = YES;
    
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barStyle)])
    {
        // Fix the scrollview being behind tabbar
        if (self.tabBarController) {
            UIEdgeInsets inset = self.tableView.contentInset;
            inset.bottom = self.tabBarController.tabBar.frame.size.height;
            self.tableView.contentInset = inset;
        }
        
        if (self.navigationController) {
            UIEdgeInsets inset = self.tableView.contentInset;
            inset.top = self.navigationController.navigationBar.frame.size.height + 20.0f; // 20.0f for the status bar
            self.tableView.contentInset = inset;
            
            CGPoint topOffset = CGPointMake(0, -inset.top);
            [self.tableView setContentOffset:topOffset animated:YES];
        }
    }
    
    [self.view addSubview:self.tableView];
    
    if (_delegate)
    {
        _activity = [_delegate currentActivity];
        [self setCommentsByActivityId:_activity.remoteId];
    }
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
    dispatch_queue_t troveQueue = dispatch_queue_create("Comments Processing Queue", NULL);
    dispatch_async(troveQueue, ^{
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(activityId like %@)", activityId];
        
        // Filter for comments related to the current activity
        NSArray *filteredList = [[SharedApiClient getClient].collections[@"comments"] filteredArrayUsingPredicate:pred];
        
        // Sort by oldest to newest
        _comments = [filteredList sortedArrayUsingComparator: ^(id a, id b) {
            NSString *first = [[a objectForKey:@"created"] objectForKey:@"$date"];
            NSString *second = [[b objectForKey:@"created"] objectForKey:@"$date"];
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
