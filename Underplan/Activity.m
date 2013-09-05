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

- (NSString *)summaryText
{
    NSString *text = self.text;
    if ([self.type isEqualToString:@"story"] && [text length] > 247) {
        text = [[text substringToIndex:247] stringByAppendingString:@"..."];
    }
    return text;
}

- (NSString *)summaryInfo
{
    // Set the info field - date and location
    NSString *created;
    NSString *city;
    NSString *country;
    if([self.created isKindOfClass:[NSMutableDictionary class]])
    {
        double dateDouble = [self.created[@"$date"] doubleValue];
        dateDouble = dateDouble/1000;
        NSDate *dateCreated = [NSDate dateWithTimeIntervalSince1970:dateDouble];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy 'at' HH:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:dateCreated];
        
        created = formattedDateString;
    }
    else
    {
        created = @"1st Jan 2013";
    }
    
    if([self.city isKindOfClass:[NSString class]])
    {
        city = self.city;
    }
    else
    {
        city = @"Perth";
    }
    
    if([self.country isKindOfClass:[NSString class]])
    {
        country = self.country;
    }
    else
    {
        country = @"Australia";
    }
    
    return [NSString stringWithFormat: @"%@ - %@, %@", created, city, country];
}

- (NSString *)photoUrl
{
    if (![self.apiClient isKindOfClass:[UnderplanApiClient class]]) {
        [NSException raise:@"UnderplanApiClientNotSpecified" format:@"Instance does not have access to UnderplanApiClient with apiClient property."];
    }
    
    Group *group = [[Group alloc] initWithIdAndUnderplanApiClient:self.groupId apiClient:self.apiClient];
    
    // If the group has trovebox settings then check the tags for a photo to match this activity
    if ([group hasTrovebox]) {
        // The tag is set based on the activity id
        NSString *photoTag = @"underplan-*";
        photoTag = [photoTag stringByReplacingOccurrencesOfString:@"*" withString:self._id];
        Photo *photo = [[Photo alloc] initWithFirstMatchByTagAndTrovebox:photoTag trovebox:group.trovebox];
        
        // TODO: return image size url based on device screen width
        return photo.medium;
    } else {
        return @"";
    }
}

@end
