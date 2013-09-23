//
//  ActivityFeedAnnotation.h
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Activity.h"

@interface ActivityFeedAnnotation : NSObject <MKAnnotation>

//@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
//@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) Activity *activity;

- (id)initWithActivity:(Activity *)anActivity;

@end
