//
//  Comment.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MeteorModel.h"
#import "UserItem.h"
#import "User.h"

@interface Comment : UserItem

@property (strong, nonatomic) NSString *activityId;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *text;

@end
