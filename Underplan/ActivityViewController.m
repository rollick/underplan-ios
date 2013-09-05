//
//  ActivityViewController.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActivityViewController.h"
#import "CommentsViewController.h"
#import "UIViewController+UnderplanApiNotifications.h"
#import "SharedApiClient.h"
#import "UnderplanUserItemView.h"

#import "User.h"
#import "Activity.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Underplan.h"

@interface ActivityViewController ()

@property (strong, nonatomic) NSMutableDictionary *owner;

- (void)setActivityDetails;

@end

@implementation ActivityViewController

@synthesize mainView;

- (void)configureApiSubscriptions
{
    // Get the full activity data
    NSArray *params = @[_activity[@"_id"]];
    [[SharedApiClient getClient] addSubscription:@"activityShow" withParamaters:params];
    [[SharedApiClient getClient] addSubscription:@"activityCommentsCount" withParamaters:params];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureApiSubscriptions];
    
    [self initView];
    [self setActivityDetails];
    
    CGRect frame = self.view.frame;
    self.mainView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.view.contentSize = CGSizeMake(self.mainView.bounds.size.width, self.mainView.bounds.size.height);
}

- (void)initView
{
    self.view = [[UIScrollView alloc] init];
//    self.view.scrollEnabled = YES;
    self.view.showsVerticalScrollIndicator = NO;
    self.view.showsHorizontalScrollIndicator = NO;
    self.view.bouncesZoom = YES;
    self.view.decelerationRate = UIScrollViewDecelerationRateFast;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.view.delegate = self;
    self.view.backgroundColor = [UIColor underplanBgColor];
    [self.view.layer setBorderColor:[UIColor redColor].CGColor];
    self.view.layer.borderWidth = 1.0f;
    
    self.mainView = [[UnderplanUserItemView alloc] init];
    [self.mainView.layer setBorderColor:[UIColor blueColor].CGColor];
    self.mainView.layer.borderWidth = 1.0f;
    
    [self.view addSubview:self.mainView];
    
    if (self.tabBarController) {
        UIEdgeInsets inset = self.view.contentInset;
        inset.bottom = self.tabBarController.tabBar.frame.size.height;
        self.view.contentInset = inset;
    }
}

- (void)setActivityDetails
{
    // Set the profile image
    User *owner = [[User alloc] initWithIdAndCollection:_activity[@"owner"]
                                             collection:[SharedApiClient getClient].collections[@"users"]];
    
    Activity *activity = [[Activity alloc] initWithIdAndUnderplanApiClient:_activity[@"_id"]
                                                                 apiClient:[SharedApiClient getClient]];
    
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [self.mainView.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    // Set the text fields
    self.mainView.detailsView.subTitle.text = [activity summaryInfo];
    self.mainView.detailsView.title.text = owner.profile[@"name"];
    self.mainView.mainText.text = activity.text;
    
    // Add some constraints
    UITextView *mainText = self.mainView.mainText;
    UnderplanItemDetailsView *detailsView = self.mainView.detailsView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    NSString *format = @"V:|-(16)-[detailsView]-16-[mainText]-(>=16)-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.mainView addConstraints:constraintsArray];
    
    if ([activity.type isEqual:@"story"]) {
        self.navigationItem.title = activity.title;
    }
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    // Refresh view if this activity was updated
    if (![[notification name] isEqualToString:@"ready"] && notification.userInfo[@"_id"] == self.activity[@"_id"]) {
        [self setActivityDetails];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc
{
    // FIXME: temp fis for ios7 issue when view is scrolling and user navigates away
    self.view.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showComments"]) {
        [[segue destinationViewController] setActivity:_activity];
    }
}

@end
