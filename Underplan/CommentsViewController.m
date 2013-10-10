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

#define COMMENT_HEIGHT 40
#define COMMENT_PADDING 8

@interface CommentsViewController ()

@property (strong, nonatomic) NSArray *comments;
@property (assign, nonatomic) Activity *activity;

@end

@implementation CommentsViewController
{
    int commentYOffset;
    int tableYOffset;
}

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
    
    if ([SharedApiClient getAuth].userID) {
        [self addCommentView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    
    if (_delegate)
    {
        _activity = [_delegate currentActivity];
        [self setCommentsByActivityId:_activity.remoteId];
    }
    
    int statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    int navHeight = self.navigationController.navigationBar.frame.size.height;
    int bottomHeight = self.tabBarController.tabBar.frame.size.height;
    if([SharedApiClient getAuth].userID)
        bottomHeight += COMMENT_HEIGHT;
    [self.tableView setContentInset:UIEdgeInsetsMake(navHeight + statusHeight, 0, bottomHeight, 0)];
}

- (void)addCommentView
{
    self.commentView = [[UIView alloc] init];
    self.commentView.layer.backgroundColor = [UIColor grayColor].CGColor;
    [self.commentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.commentView];
    [self.view bringSubviewToFront:self.commentView];
    
    UITextField *commentBox = [[UITextField alloc] init];
    commentBox.layer.backgroundColor = [UIColor whiteColor].CGColor;
    commentBox.layer.cornerRadius = 2.0f;
    commentBox.delegate = self;
//    commentBox.inputAccessoryView = self.commentView;
    [commentBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.commentView addSubview:commentBox];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.titleLabel.font = [UIFont fontWithName:@"Gruppo" size:20];
    int inset = (COMMENT_HEIGHT - COMMENT_PADDING*2 - 20) / 2;
    cancelBtn.titleEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
//    [self.loginButton setTitleColor:[UIColor underplanPrimaryDarkColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"X" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor underplanDarkMenuFontColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelComment:) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.layer.backgroundColor = [UIColor greenColor].CGColor;
    [cancelBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.commentView addSubview:cancelBtn];
    
    NSDictionary *metrics = @{@"padding": @COMMENT_PADDING,
                              @"height": @COMMENT_HEIGHT,
                              @"bottomPadding": [NSNumber numberWithFloat:self.tabBarController.tabBar.frame.size.height],
                              @"btnWidth": @(COMMENT_HEIGHT-COMMENT_PADDING-COMMENT_PADDING)};
    
    [self.commentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[commentBox]-[cancelBtn(btnWidth)]-(padding)-|"
                                                                      options:NSLayoutFormatAlignAllTop
                                                                             metrics:metrics
                                                                        views:@{@"commentBox": commentBox,
                                                                                @"cancelBtn": cancelBtn}]];
    
    [self.commentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[commentBox]-(padding)-|"
                                                                             options:NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight
                                                                             metrics:metrics
                                                                               views:@{@"commentBox": commentBox,
                                                                                @"cancelBtn": cancelBtn}]];

    [self.commentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[cancelBtn]-(padding)-|"
                                                                             options:NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight
                                                                             metrics:metrics
                                                                               views:@{@"commentBox": commentBox,
                                                                                       @"cancelBtn": cancelBtn}]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[commentView]-0-|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:@{@"commentView": self.commentView}]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[commentView(height)]-(bottomPadding)-|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:@{@"commentView": self.commentView}]];
}

- (void)cancelComment:(id)sender
{
    for (UIView *view in self.commentView.subviews)
    {
        if ([view respondsToSelector:@selector(resignFirstResponder)])
            [view resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] > 0)
    {
        [[SharedApiClient getClient] sendWithMethodName:@"createComment"
                                             parameters:@[@{@"comment": textField.text,
                                                            @"activityId": _activity.remoteId,
                                                            @"groupId": _activity.groupId}]];
        
        textField.text = @"";
        [self cancelComment:nil];
    }
    
    return YES;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    double animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UnderplanBasicLabel setHidden:YES view:self.view];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CALayer *layer = self.commentView.layer;
                         commentYOffset = layer.frame.origin.y;
                         
                         [self.commentView setFrame:CGRectMake(layer.frame.origin.x, commentYOffset - kbSize.height + self.tabBarController.tabBar.frame.size.height, layer.frame.size.width, layer.frame.size.height)];
                     }
                     completion:nil];
    
    tableYOffset = self.tableView.contentInset.bottom;
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, tableYOffset + kbSize.height - self.tabBarController.tabBar.frame.size.height, 0)];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CALayer *layer = self.commentView.layer;
                         
                         [self.commentView setFrame:CGRectMake(layer.frame.origin.x, commentYOffset, layer.frame.size.width, layer.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UnderplanBasicLabel setHidden:NO view:self.view];
                     }];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, tableYOffset, 0)];
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
    

//    if (self.commentView)
//        int commentYOffset ;
//        [self.commentView setFrame:CGRectMake(layer.frame.origin.x, commentYOffset, layer.frame.size.width, layer.frame.size.height)];
    
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
//    NSString *_id = notification.userInfo[@"activityId"];
//    if ([_id isEqualToString:_activity.remoteId])
//    {
//        [self setCommentsByActivityId:_id];
//    }
    if ([[notification name] isEqualToString:@"activityComments_ready"])
    {
        [self setCommentsByActivityId:_activity.remoteId];
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
            NSNumber *first;
            NSNumber *second;

            // FIXME:   Hack! There is some data on the server which hasn't been converted
            //          to a date correctly. It is a string like "2012-11-10T08:21:59". It
            //          is still good for sorting
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
            if ([[a objectForKey:@"created"] isKindOfClass:[NSString class]])
            {
                NSDate *aDate = [df dateFromString:[a objectForKey:@"created"]];
                first = [NSNumber numberWithDouble:aDate.timeIntervalSince1970];
            }
            else
                first = [[a objectForKey:@"created"] objectForKey:@"$date"];
            
            if ([[b objectForKey:@"created"] isKindOfClass:[NSString class]])
            {
                NSDate *aDate = [df dateFromString:[b objectForKey:@"created"]];
                second = [NSNumber numberWithDouble:aDate.timeIntervalSince1970];
            }
            else
                second = [[b objectForKey:@"created"] objectForKey:@"$date"];
            
            return [first compare:second];
        }];
        
        // perform UI updates in the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
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
