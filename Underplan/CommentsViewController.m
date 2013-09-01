//
//  CommentsViewController.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "CommentsViewController.h"
#import "UIViewController+UnderplanApiNotifications.h"
#import "SharedApiClient.h"

#import "UserItemView.h"

#import "User.h"
#import "Comment.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIColor+HexString.h>

@interface CommentsViewController ()

@property (strong, nonatomic) NSDictionary *activity;

@end

@implementation CommentsViewController

- (void)configureApiSubscriptions
{
    NSArray *params = @[_activity[@"_id"]];
    [[SharedApiClient getClient] addSubscription:@"activityComments" withParamaters:params];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UINib *cellNib = [UINib nibWithNibName:@"UserItemView" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"item"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated

{
    [super viewWillAppear:animated];
    [self configureApiSubscriptions];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.navigationItem.title = @"Comments";
}

#pragma mark - Table View

- (NSArray *)computedList {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(activityId like %@)", self.activity[@"_id"]];
    return [[SharedApiClient getClient].collections[@"comments"] filteredArrayUsingPredicate:pred];
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    // TODO: look into the correct use of the ready, added, removed notifcations
    //       for table cells and meteor etc.
    //    if([[notification name] isEqualToString:@"ready"]) {
    //        [self reloadFeedMap];
    //        [self.tableView reloadData];
    //    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.computedList count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UserItemView *cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
//    NSDictionary *comment = self.computedList[indexPath.row];
//    NSString *text = comment[@"comment"];
//    
//    return [cell cellHeight:text];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"item";
    UserItemView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *_comment = self.computedList[indexPath.row];
    
    Comment *comment = [[Comment alloc] initWithIdAndUnderplanApiClient:_comment[@"_id"]
                                                                 apiClient:[SharedApiClient getClient]];
    
    // Fetch owner
    User *owner = [[User alloc] initWithIdAndCollection:comment.owner collection:[SharedApiClient getClient].collections[@"users"]];
    
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

    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#E5E5E5"];
    
    return cell;
}

@end
