//
//  Activity.h
//  Underplan
//
//  Created by Mark Gallop on 6/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MeteorModel.h"

@interface Activity : MeteorModel

@property (assign, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *region;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSMutableDictionary *created;

- (NSString *)summaryInfo;
- (NSString *)photoUrl;

@end
