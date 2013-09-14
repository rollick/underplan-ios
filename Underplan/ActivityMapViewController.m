//
//  ActivityMapViewController.m
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityMapViewController.h"
#import "ActivityFeedAnnotation.h"
#import "UIViewController+UnderplanApiNotifications.h"
#import "SharedApiClient.h"

#import "UIColor+Underplan.h"

@interface ActivityMapViewController ()

@end

#define THE_SPAN 0.10f;
#define MINIMUM_ZOOM_ARC 0.05
#define ANNOTATION_REGION_PAD_FACTOR 1.25
#define MAX_DEGREES_ARC 360

@implementation ActivityMapViewController

- (void)configureApiSubscriptions
{
    NSArray *params = @[_group.remoteId];
    [[SharedApiClient getClient] addSubscription:@"basicActivityData" withParameters:params];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveApiUpdate:)
                                                     name:@"basicActivityData_ready"
                                                   object:nil];
        
        MKCoordinateRegion worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld);
        _feedMapView.region = worldRegion;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_delegate)
    {
        _group = [_delegate currentGroup];
        _activity = [_delegate currentActivity];
    }
    
    [self configureApiSubscriptions];
    self.navigationItem.title = @"Map";
    
    // FIXME:   This is a hack when the willdisappear of the gallery controller
    //          wasn't re-setting the tabbar reliably
//    [self.tabBarController.tabBar setTintColor:[UIColor redColor]];
//    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
//
//    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
//    {
//        [self.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
//        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

//    [self.tabBarController.tabBar setTintColor:[UIColor underplanPrimaryColor]];
//    [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryColor]];
//    
//    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
//    {
//        [self.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
//        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    [self reloadData];
//    UIBarButtonItem *zoomToFitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_out.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomMapViewToFitAnnotations)];
//    self.navigationItem.rightBarButtonItem = zoomToFitButton;
    
    [self zoomMapViewToFitAnnotations:_feedMapView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    // TODO: look into the correct use of the ready, added, removed notifcations
    //       for table cells and meteor etc.
    if([[notification name] isEqualToString:@"basicActivityData_ready"]) {
        [self reloadData];
        [self zoomMapViewToFitAnnotations:_feedMapView animated:YES];
    }
}

- (NSArray *)computedList {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(group like %@)", self.group.remoteId];
    return [[SharedApiClient getClient].collections[@"activities"] filteredArrayUsingPredicate:pred];
}

- (void)zoomMapViewToFitAnnotations
{
    [self zoomMapViewToFitAnnotations:_feedMapView animated:YES];
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

-(void)reloadData
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
    }
}

@end
