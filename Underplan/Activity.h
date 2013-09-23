//
//  Activity.h
//  Underplan
//
//  Created by Mark Gallop on 6/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "MeteorModel.h"
#import "Group.h"
#import "User.h"

@interface Activity : MeteorModel

@property (strong, nonatomic) NSString *ownerId;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *region;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *tags;
@property (strong, nonatomic) NSMutableDictionary *created;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (retain, nonatomic, readonly) User *owner;
@property (retain, nonatomic, readonly) Group *group;

- (NSString *)summaryInfo;
- (NSString *)photoUrl;
- (NSString *)summaryText;

@end
