//
//  CommentsViewController.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "CommentsViewController.h"

#import "UserItemView.h"

#import "User.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface CommentsViewController ()

@property (strong, nonatomic) NSDictionary *activity;

- (void)configureMeteor;

@end

@implementation CommentsViewController

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
    NSArray *params = @[_activity[@"_id"]];
    [_meteor addSubscription:@"activityComments"
                  parameters:params];
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
    self.navigationItem.title = @"Comments";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"added"
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

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View

- (void)didReceiveUpdate:(NSNotification *)notification
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
    return [_meteor.collections[@"comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserItemView *cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
    NSDictionary *comment = _meteor.collections[@"comments"][indexPath.row];
    NSString *text = comment[@"comment"];
    
    return [cell cellHeight:text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"item";
    UserItemView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *comment = _meteor.collections[@"comments"][indexPath.row];
    
    // Fetch owner
    User *owner = [[User alloc] initWithCollectionAndId:self.meteor.collections[@"users"]
                                                     id:comment[@"owner"]];
    
    // Set the profile image
    // TODO: Maybe the activity cell needs to have a custom view which can
    //       be notified when the owner details are available....
    
    // Set the owners name as the title
    if([comment[@"owner"] isKindOfClass:[NSString class]])
    {
        cell.title.text = owner.profile[@"name"];
    }
    else
    {
        cell.title.text = @"No title :-(";
    }
    
    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    [cell.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    // Set the info field - date and location
    NSString *created;
    if([comment[@"created"] isKindOfClass:[NSMutableDictionary class]])
    {
        double dateDouble = [comment[@"created"][@"$date"] doubleValue];
        dateDouble = dateDouble/1000;
        NSDate *dateCreated = [NSDate dateWithTimeIntervalSince1970:dateDouble];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy 'at' HH:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:dateCreated];
        
        created = formattedDateString;
    }
    else
    {
        created = @"1st Jan 2013";
    }
    
    cell.subTitle.text = created;
    
    if([comment[@"comment"] isKindOfClass:[NSString class]])
    {
        cell.mainText.text = comment[@"comment"];
    }
    else
    {
        cell.mainText.text = @"-";
    }

    return cell;
}

@end
