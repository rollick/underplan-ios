//
//  ActivityMapViewController.h
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanViewController.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "UnderplanApiClient.h"
#import "Group.h"

@interface ActivityMapViewController : UnderplanViewController

@property (retain, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet MKMapView *feedMapView;

- (void)reloadData;

@end
