//
//  ActivityViewController.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityViewController.h"
#import "CommentsViewController.h"

#import "User.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ActivityViewController ()

@property (strong, nonatomic) NSMutableDictionary *owner;

- (void)setActivityDetails;

@end

@implementation ActivityViewController

- (void)setActivity:(id)newActivity
{
    if (_activity != newActivity) {
        _activity = newActivity;
    }
}

- (void)setMeteor:(id)newMeteor
{
    if (_meteor != newMeteor) {
        _meteor = newMeteor;
        
        // Update the view.
        [self configureMeteor];
    }
}

- (void)configureMeteor
{
    // Get the full activity data
    NSArray *params = @[_activity[@"_id"]];
    [_meteor addSubscriptionWithParameters:@"activityShow" paramaters:params];
    [_meteor addSubscriptionWithParameters:@"activityCommentsCount" paramaters:params];
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
	// Do any additional setup after loading the view.
    
    CGRect frame = _activityText.frame;
    frame.size.height = _activityText.contentSize.height;
    _activityText.frame = frame;
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    [self setActivityDetails];
}

- (void)setActivityDetails
{
    // Set the profile image
    User *owner = [[User alloc] initWithIdAndCollection:_activity[@"owner"]
                                             collection:self.meteor.collections[@"users"]];
    
    UIImageView *profileImage = (UIImageView *)[self.view viewWithTag:100];
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [profileImage setImageWithURL:[NSURL URLWithString:profileImageUrl]
                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]];        
    }
    
    _activityText.contentInset = UIEdgeInsetsMake(-4,-8,-8,-8);
    
    // Set the text fields
    _activityText.text = _activity[@"text"];
    
    if([_activity[@"title"] isKindOfClass:[NSString class]])
    {
        _activityTitle.text = _activity[@"title"];
    }
    else
    {
        _activityTitle.text = @"Testing";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Activities";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"changed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"removed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"ready"
                                               object:nil];
}

- (void)didReceiveUpdate:(NSNotification *)notification
{
    // Refresh view if this activity was updated
    if (notification.userInfo[@"_id"] == self.activity[@"_id"]) {
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
        [[segue destinationViewController] setMeteor:_meteor];
    }
}

@end
