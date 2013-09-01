//
//  Comment.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MeteorModel.h"

@interface Comment : MeteorModel

@property (assign, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *activityId;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSMutableDictionary *created;

@end
