//
//  ActivityFeedAnnotation.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityFeedAnnotation.h"

@implementation ActivityFeedAnnotation

- (id)initWithActivity:(Activity *)anActivity
{
    if (self = [self init])
    {
        _activity = anActivity;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    if (![self validCoordinate])
        return theCoordinate;
    
    theCoordinate.latitude = [_activity.latitude doubleValue];
    theCoordinate.longitude = [_activity.longitude doubleValue];
    
    return theCoordinate;
}

- (bool)validCoordinate
{
    return !!_activity.latitude && !!_activity.longitude;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    if (_activity.title && ![_activity.title isKindOfClass:[NSNull class]])
    {
        return _activity.title;
    }
    else
    {
        if (_activity.owner)
            return [[NSString alloc] initWithFormat:@"By %@", _activity.owner.profile[@"name"]];
        else
            return @"A Shorty";
    }
}

// optional
- (NSString *)subtitle
{
    return _activity.summaryInfo;
}

@end
