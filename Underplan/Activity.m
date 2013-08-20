//
//  Activity.m
//  Underplan
//
//  Created by Mark Gallop on 6/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "Activity.h"
#import "Group.h"
#import "Photo.h"

@implementation Activity

// Override this in the subclass
- (NSString *)collectionName
{
    return @"activities";
}

// Override this in the subclass
- (BOOL)processApiData: (NSDictionary *)data_
{
    self._id = data_[@"_id"];
    self.owner = data_[@"owner"];
    self.groupId = data_[@"group"];
    self.type = data_[@"type"];
    self.title = data_[@"title"];
    self.text = data_[@"text"];
    self.city = data_[@"city"];
    self.region = data_[@"region"];
    self.country = data_[@"country"];
    self.created = data_[@"created"];
    
    return true;
}

- (NSString *)photoUrl
{
    if (![self.meteor isKindOfClass:[MeteorClient class]]) {
        [NSException raise:@"MeteorClientNotSpecified" format:@"Instance does not have access to MeteorClient with meteor property."];
    }
    
    Group *group = [[Group alloc] initWithIdAndMeteorClient:self.groupId meteor:self.meteor];
    
    // If the group has trovebox settings then check the tags for a photo to match this activity
    if ([group hasTrovebox]) {
        // The tag is set based on the activity id
        NSString *photoTag = @"underplan-*";
        photoTag = [photoTag stringByReplacingOccurrencesOfString:@"*" withString:self._id];
        Photo *photo = [[Photo alloc] intWithFirstMatchByTagAndTrovebox:photoTag trovebox:group.trovebox];
        
        // TODO: return image size url based on device screen size
        return photo.medium;
    } else {
        return @"";
    }
    

}

@end
