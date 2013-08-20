//
//  Group.m
//  Underplan
//
//  Created by Mark Gallop on 6/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "Group.h"

@implementation Group

- (NSString *)collectionName
{
    return @"groups";
}

- (BOOL)processApiData: (NSDictionary *)data_
{
    self._id = data_[@"_id"];
    self.owner = data_[@"owner"];
    self.name = data_[@"name"];
    self.description = data_[@"description"];
    self.trovebox = data_[@"trovebox"];
    
    return true;
}

- (BOOL)hasTrovebox
{
    return [self.trovebox isKindOfClass:[NSDictionary class]];
}

@end
