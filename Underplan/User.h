//
//  User.h
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MeteorModel.h"

@interface User : MeteorModel

@property (assign, nonatomic) NSString *_id;
@property (strong, nonatomic) NSNumber *admin;
@property (strong, nonatomic) NSDictionary *profile;
@property (strong, nonatomic) NSDictionary *services;

- (NSString *)profileImageUrl:(NSNumber *)size;

@end
