//
//  ActivityMapViewController.m
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityMapViewController.h"
#import "ActivityFeedAnnotation.h"
#import "ActivityTabBarController.h"

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
        self.feedMapView.region = worldRegion;
        
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
    
//    [self zoomMapViewToFitAnnotations:_feedMapView animated:YES];
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
    for(NSDictionary *activityData in self.computedList)
    {
        // Annotate the map
        Activity *activity = [[Activity alloc] initWithId:activityData[@"_id"]];
        ActivityFeedAnnotation *activityAnnotation = [[ActivityFeedAnnotation alloc] initWithActivity:activity];
            
        [self.feedMapView addAnnotation:activityAnnotation];
    }
}

#pragma mark - MKMapViewDelegate

// user tapped the disclosure button in the callout
//
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // here we illustrate how to detect which annotation type was clicked on for its callout
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[ActivityFeedAnnotation class]])
    {
        [self performSegueWithIdentifier:@"showActivity" sender:annotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(ActivityFeedAnnotation <MKAnnotation>*)annotation
{
//    CLLocationCoordinate2D activityLocation;
    // try to dequeue an existing pin view first
    static NSString *FeedAnnotationIdentifier = @"feedAnnotationIdentifier";
    
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *) [_feedMapView dequeueReusableAnnotationViewWithIdentifier:FeedAnnotationIdentifier];
    if (pinView == nil)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:FeedAnnotationIdentifier];
        if ([[annotation activity].type isEqualToString:@"story"]) {
            customPinView.pinColor = MKPinAnnotationColorGreen;
        }
        else
        {
            customPinView.pinColor = MKPinAnnotationColorRed;
        }
        
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        // add a detail disclosure button to the callout which will open a new view controller page
        //
        // note: when the detail disclosure button is tapped, we respond to it via:
        //       calloutAccessoryControlTapped delegate method
        //
        // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
        //
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        return customPinView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    
    return pinView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showActivity"]) {
        Activity *activity = [sender activity];
        
        id controller = [segue destinationViewController];
        if ([controller respondsToSelector:@selector(activity)]) {
            [controller setValue:activity forKey:@"activity"];
        }
        if ([controller respondsToSelector:@selector(group)]) {
            [controller setValue:activity.group forKey:@"group"];
        }
    }
}

@end
