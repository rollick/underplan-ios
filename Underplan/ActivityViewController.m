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
#import "ItemDetailsView.h"

#import "User.h"
#import "Activity.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+HexString.h"

@interface ActivityViewController ()

@property (strong, nonatomic) NSMutableDictionary *owner;

- (void)setActivityDetails;

@end

@implementation ActivityViewController

@synthesize detailsView, mainText, contentImage;

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

    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];

    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureApiSubscriptions];
    
    [self initView];
    [self setActivityDetails];
}

- (void)initView
{
    self.view = [[UIView alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.detailsView = [[ItemDetailsView alloc] init];
    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:detailsView];
    
    self.mainText = [[UITextView alloc] init];
    self.mainText.autoresizingMask = ( UIViewAutoresizingFlexibleHeight );
    self.mainText.contentInset = UIEdgeInsetsMake(-8,-4,-4,-4);
        [self.mainText setFont:[UIFont fontWithName:@"Helvetica-Light" size:14]];
    [self.mainText setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:mainText];

    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    NSString *format = @"V:|-15-[detailsView]-15-[mainText]-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.view addConstraints:constraintsArray];
    
    format = @"|-15-[mainText]-15-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.view addConstraints:constraintsArray];
    
    format = @"|-15-[detailsView]-15-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.view addConstraints:constraintsArray];
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
        [self.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    // Set the text fields
    self.detailsView.subTitle.text = [activity summaryInfo];
    self.detailsView.title.text = owner.profile[@"name"];
    self.mainText.text = activity.text;
    
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
