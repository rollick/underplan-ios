//
//  ActivityMapViewController.h
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanViewController.h"

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>
#import <MapKit/MapKit.h>

@interface ActivityMapViewController : UnderplanViewController

@property (copy, nonatomic) NSDictionary *group;
@property (strong, nonatomic) MeteorClient *meteor;

@property (weak, nonatomic) IBOutlet MKMapView *feedMapView;

- (void)reloadData;
- (void)setMeteor:(MeteorClient *)newMeteor;

@end
