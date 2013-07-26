//
//  CommentsViewController.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "CommentsViewController.h"

#import "User.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface CommentsViewController ()

@property (strong, nonatomic) NSDictionary *activity;
@property (strong, nonatomic) NSMutableArray *comments;

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
    NSArray *params = @[@{@"activityId":_activity[@"_id"]}];
    [_meteor addSubscription:@"feedComments"
                  parameters:params];
    
    // Update the user interface for the group
    _comments = _meteor.collections[@"comments"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    return _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Comment";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *comment = _comments[indexPath.row];
    
    // Fetch owner
    User *owner = [[User alloc] initWithCollectionAndId:self.meteor.collections[@"users"]
                                                     id:comment[@"owner"]];
    
    // Set the profile image
    // TODO: Maybe the activity cell needs to have a custom view which can
    //       be notified when the owner details are available....
    
    // Set the owners name as the title
    UILabel *title = (UILabel *)[cell viewWithTag:200];
    if([comment[@"owner"] isKindOfClass:[NSString class]])
    {
        title.text = owner.profile[@"name"];
    }
    else
    {
        title.text = @"No title :-(";
    }
    
    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    //        // The image url needs to be tweaked based on the login service used
    //        if (owner.services[@"google"])
    //        {
    //            // Add sz=75 etc to url
    //            // NOTE: the size should very based on the device...
    //            profileImageUrl = [profileImageUrl stringByAppendingString:@"?sz=144"];
    //        } else if (owner.services[@"facebook"])
    //        {
    //            // Add ?width=75 to url
    //            profileImageUrl = [profileImageUrl stringByAppendingString:@"?width=144"];
    //        }
    
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:100];
    [profileImage setImageWithURL:[NSURL URLWithString:profileImageUrl]
                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    // Set the info field - date and location
    UILabel *info = (UILabel *)[cell viewWithTag:300];
    NSString *created;
    NSString *city;
    NSString *country;
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
    
    if([comment[@"city"] isKindOfClass:[NSString class]])
    {
        city = comment[@"city"];
    }
    else
    {
        city = @"Perth";
    }
    
    if([comment[@"country"] isKindOfClass:[NSString class]])
    {
        country = comment[@"country"];
    }
    else
    {
        country = @"Australia";
    }
    
    info.text = [NSString stringWithFormat: @"%@ - %@, %@", created, city, country];
    
    UILabel *description = (UILabel *)[cell viewWithTag:400];
    if([comment[@"comment"] isKindOfClass:[NSString class]])
    {
        description.text = comment[@"comment"];
    }
    else
    {
        description.text = @"-";
    }
    //    [description setNumberOfLines:0];
    //    CGSize textSize = [description.text sizeWithFont:description.font constrainedToSize:CGSizeMake(description.frame.size.width, MAXFLOAT) lineBreakMode:description.lineBreakMode];
    //    description.frame = CGRectMake(20.0f, 20.0f, textSize.width, textSize.height);
    //    
    return cell;
}

@end
