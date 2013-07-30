//
//  GroupViewController.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityViewController.h"

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>
#import <MapKit/MapKit.h>

@interface GroupViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) ActivityViewController *activityViewController;

@property (copy, nonatomic) NSDictionary *group;
@property (strong, nonatomic) MeteorClient *meteor;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *feedMapView;

@end
