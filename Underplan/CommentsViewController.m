//
//  CommentsViewController.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "CommentsViewController.h"
#import "SharedApiClient.h"

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

- (id)initWithDelegate:(id <UnderplanActivityAwareDelegate>)aDelegate
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
    
    if (_delegate)
    {
        _activity = [_delegate currentActivity];
        [self setCommentsByActivityId:_activity.remoteId];
    }
    
    self.view = [[UIView alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.view.backgroundColor = [UIColor underplanBgColor];
    self.tableView.backgroundColor = [UIColor underplanBgColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    
    [self.view addSubview:self.tableView];
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

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(activityId like %@)", activityId];
    _comments = [[SharedApiClient getClient].collections[@"comments"] filteredArrayUsingPredicate:pred];
    [_delegate updateCommentsCount:self count:[_comments count]];
    
    [self.tableView reloadData];
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
    
    // Fetch owner
    User *owner = [[User alloc] initWithId:comment.ownerId];
    
    // Set the profile image
    // TODO: Maybe the activity cell needs to have a custom view which can
    //       be notified when the owner details are available....
    
    // Set the owners name as the title
    cell.detailsView.title.text = owner.profile[@"name"];
    
    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    [cell.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    // Set the info field - date and location
    NSString *created;
    if([comment.created isKindOfClass:[NSMutableDictionary class]])
    {
        double dateDouble = [comment.created[@"$date"] doubleValue];
        dateDouble = dateDouble/1000;
        NSDate *dateCreated = [NSDate dateWithTimeIntervalSince1970:dateDouble];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy 'at' HH:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:dateCreated];
        
        created = formattedDateString;
    }
    else
    {
        created = @"-";
    }
    
    cell.detailsView.subTitle.text = created;
    cell.mainText.text = comment.text;

    self.tableView.backgroundColor = [UIColor underplanBgColor];
    
    return cell;
}

@end
