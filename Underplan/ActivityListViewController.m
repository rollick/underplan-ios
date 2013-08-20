//
//  ActivityListViewController.m
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityListViewController.h"
#import "UnderplanAppDelegate.h"
#import "ActivityViewController.h"
#import "UserItemView.h"
#import "UITabBarController+ShowHideBar.h"

#import "User.h"
#import "Activity.h"
#import "Photo.h"

#import "BSONIdGenerator.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <MapKit/MapKit.h>

@interface ActivityListViewController ()

@end

@implementation ActivityListViewController {
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
}

#pragma mark - Meteor stuff

- (void)setMeteor:(MeteorClient *)newMeteor
{
    if (_meteor != newMeteor) {
        _meteor = newMeteor;
    }
}

- (void)setActivities:(NSMutableArray *)newActivities
{
    if (_activities != newActivities) {
        _activities = newActivities;
    }
}

- (void)setGroup:(id)newGroup
{
    if (_group != newGroup) {
        _group = newGroup;
    }
}

#pragma mark - Managing the activity details

-(void)reloadData
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UINib *cellNib = [UINib nibWithNibName:@"UserItemView" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"item"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSArray *)computedList {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(group like %@)", self.group[@"_id"]];
    return [self.meteor.collections[@"activities"] filteredArrayUsingPredicate:pred];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Activities";
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserItemView *cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
    NSDictionary *activity = self.computedList[indexPath.row];
    NSString *text = activity[@"text"];
    
    return [cell cellHeight:text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection returning %d", [self.computedList count]);
    return [self.computedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"item";
    UserItemView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    tableView.separatorColor = [UIColor clearColor];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSDictionary *activityData = self.computedList[indexPath.row];
    Activity *activity = [[Activity alloc] initWithIdAndMeteorClient:activityData[@"_id"]
                                                              meteor:self.meteor];
    
    // Fetch owner 
    User *owner = [[User alloc] initWithIdAndMeteorClient:activity.owner
                                                   meteor:self.meteor];

    // Set the owners name as the title
    if([activity.owner isKindOfClass:[NSString class]])
    {
        cell.title.text = owner.profile[@"name"];
    }
    else
    {
        cell.title.text = @"No title :-(";
    }
    
    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [cell.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    // Set the info field - date and location
    NSString *created;
    NSString *city;
    NSString *country;
    if([activity.created isKindOfClass:[NSMutableDictionary class]])
    {
        double dateDouble = [activity.created[@"$date"] doubleValue];
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

    if([activity.city isKindOfClass:[NSString class]])
    {
        city = activity.city;
    }
    else
    {
        city = @"Perth";
    }
    
    if([activity.country isKindOfClass:[NSString class]])
    {
        country = activity.country;
    }
    else
    {
        country = @"Australia";
    }
    
    cell.subTitle.text = [NSString stringWithFormat: @"%@ - %@, %@", created, city, country];
    
    if([activity.text isKindOfClass:[NSString class]])
    {
        cell.mainText.text = activity.text;
    }
    else
    {
        cell.mainText.text = @"-";
    }
    
    // Set the shorty photo if available
    if ([activity.type isEqual:@"short"])
    {
        NSInteger height = 150;
        
        NSString *photoUrl = [activity photoUrl];
        if (photoUrl && ![photoUrl isEqual:@""])
        {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadWithURL:[[NSURL alloc] initWithString:photoUrl]
                             options:0
                            progress:^(NSUInteger receivedSize, long long expectedSize)
                            {
                                // progression tracking code
                            }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                            {
                                if (image)
                                {
                                    double x = (image.size.width - cell.contentImage.frame.size.width) / 2.0;
                                    double y = (image.size.height - height) / 2.0;
                                    
                                    CGRect cropRect = CGRectMake(x, y, cell.contentImage.frame.size.width, height);
                                    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                                    
                                    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
                                    CGImageRelease(imageRef);
                                    
                                    cell.contentImage.image = cropped;
                                    cell.contentImage.contentMode = UIViewContentModeScaleAspectFill;
                                    cell.photoHeight.constant = height;
                                }
                            }];
        } else {
            cell.contentImage.image = nil;
            cell.photoHeight.constant = 0;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showActivity" sender:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showActivity"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *object = self.computedList[indexPath.row];
        [[segue destinationViewController] setActivity:object];
        [[segue destinationViewController] setMeteor:self.meteor];
    }
}


#pragma mark - Scroll / Hide Stuff

-(void)expand
{
    if(hidden)
        return;
    
    hidden = YES;
    
    [self.tabBarController setHidden:YES];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
}

-(void)contract
{
    if(!hidden)
        return;
    
    hidden = NO;
    
    [self.tabBarController setHidden:NO];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
    //NSLog(@"scrollViewWillBeginDragging: %f", scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast = lastContentOffset - currentOffset;
    lastContentOffset = currentOffset;
    
    if((differenceFromStart) < 0)
    {
        // scroll up
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self expand];
    }
    else {
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self contract];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self contract];
    return YES;
}


@end
