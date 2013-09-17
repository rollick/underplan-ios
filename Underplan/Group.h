//
//  Group.h
//  Underplan
//
//  Created by Mark Gallop on 6/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeteorModel.h"

@interface Group : MeteorModel

@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *details;
@property (strong, nonatomic) NSDictionary *trovebox;

- (BOOL)hasTrovebox;

@end
