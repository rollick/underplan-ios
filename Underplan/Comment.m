//
//  Comment.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

// Override this in the subclass
- (NSString *)collectionName
{
    return @"comments";
}

// Override this in the subclass
- (BOOL)processApiData: (NSDictionary *)data_
{
    self.remoteId = data_[@"_id"];
    self.ownerId = data_[@"owner"];
    self.groupId = data_[@"groupId"];
    self.activityId = data_[@"activityId"];
    self.text = data_[@"comment"];
    self.created = data_[@"created"];
    
    return true;
}

- (User *)owner
{
    return [[User alloc] initWithId:self.ownerId];
}

@end
