//
//  User.h
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSDictionary

@property (assign) NSNumber *_id;
@property (assign) NSNumber *admin;
@property (assign) NSDictionary *profile;
@property (assign) NSDictionary *services;

- (id)initWithData:(NSDictionary *)data_;
- (id)initWithCollectionAndId: (NSMutableArray *)collection_ id:(NSString *)id_;
- (NSString *)profileImageUrl:(NSNumber *)size;

@end
