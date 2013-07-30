//
//  GroupViewController.m
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "GroupViewController.h"
#import "UnderplanAppDelegate.h"
#import "ActivityFeedAnnotation.h"
#import "ActivityViewController.h"
#import "UserItemView.h"

#import "User.h"

#import "BSONIdGenerator.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <MapKit/MapKit.h>

@interface GroupViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSMutableArray *_activities;

- (void)configureMeteor;
@end

@implementation GroupViewController

#define THE_SPAN 0.10f;
#define MINIMUM_ZOOM_ARC 0.014
#define ANNOTATION_REGION_PAD_FACTOR 2.15
#define MAX_DEGREES_ARC 360

#pragma mark - Managing the activity details

- (void)setGroup:(id)newGroup
{
    if (_group != newGroup) {
        _group = newGroup;
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
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
    NSArray *params = @[@{@"groupId":_group[@"_id"], @"limit":@99}];
    [_meteor addSubscription:@"feedActivities"
                  parameters:params];
    
    // Update the user interface for the group.
    self._activities = self.meteor.collections[@"activities"];
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
    return [[[self.meteor.collections[@"activities"] filteredArrayUsingPredicate:pred] reverseObjectEnumerator] allObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Activities";
    
    MKCoordinateRegion worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld);
    _feedMapView.region = worldRegion;
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
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

- (void)didReceiveUpdate:(NSNotification *)notification
{
    [self reloadFeedMap];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reloadFeedMap
{
    // TODO: do this once loading subscription has completed
    if([self.computedList count] != 0) {
        
        // Annotate the map
        NSMutableArray * activityLocations = [[NSMutableArray alloc] init];
        CLLocationCoordinate2D activityLocation;
        ActivityFeedAnnotation * activityAnnotation;
        NSString *title;
        NSString *subtitle;
        
        for(NSDictionary *activity in self.computedList)
        {
            activityAnnotation = [[ActivityFeedAnnotation alloc] init];
            
            activityLocation.latitude = [activity[@"lat"] floatValue];
            activityLocation.longitude = [activity[@"lng"] floatValue];
            
            activityAnnotation.coordinate = activityLocation;
            
            if([activity[@"title"] isKindOfClass:[NSString class]])
            {
                title = activity[@"title"];
                activityAnnotation.title = title;
            }
            else
            {
                activityAnnotation.title = @"Testing";
            }
            
            if([activity[@"city"] isKindOfClass:[NSString class]])
            {
                subtitle = activity[@"city"];
                activityAnnotation.subtitle = subtitle;
            }
            else
            {
                activityAnnotation.subtitle = @"Sub Testing";
            }
            
            [activityLocations addObject:activityAnnotation];
        }
        
        [self.feedMapView addAnnotations:activityLocations];
        
        [self zoomMapViewToFitAnnotations:_feedMapView animated:FALSE];
    }
}

//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    NSArray *annotations = mapView.annotations;
    int count = [mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
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
    return [self.computedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"item";
    UserItemView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSDictionary *activity = self.computedList[indexPath.row];
    
    // Fetch owner 
    User *owner = [[User alloc] initWithCollectionAndId:self.meteor.collections[@"users"]
                                                     id:activity[@"owner"]];

    // Set the profile image
    // TODO: Maybe the activity cell needs to have a custom view which can
    //       be notified when the owner details are available....

    // Set the owners name as the title
    if([activity[@"owner"] isKindOfClass:[NSString class]])
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
    NSString *city;
    NSString *country;
    if([activity[@"created"] isKindOfClass:[NSMutableDictionary class]])
    {
        double dateDouble = [activity[@"created"][@"$date"] doubleValue];
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

    if([activity[@"city"] isKindOfClass:[NSString class]])
    {
        city = activity[@"city"];
    }
    else
    {
        city = @"Perth";
    }
    
    if([activity[@"country"] isKindOfClass:[NSString class]])
    {
        country = activity[@"country"];
    }
    else
    {
        country = @"Australia";
    }
    
    cell.subTitle.text = [NSString stringWithFormat: @"%@ - %@, %@", created, city, country];
    
    if([activity[@"text"] isKindOfClass:[NSString class]])
    {
        cell.mainText.text = activity[@"text"];
    }
    else
    {
        cell.mainText.text = @"-";
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

@end
