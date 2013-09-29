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
#import "User.h"

#import "SharedApiClient.h"

@interface Activity ()

@property (retain, nonatomic) NSString *mainPhotoUrl;

@end

@implementation Activity

// Override this in the subclass
- (NSString *)collectionName
{
    return @"activities";
}

// Override this in the subclass
- (BOOL)processApiData: (NSDictionary *)data_
{
    self.remoteId = data_[@"_id"];
    self.ownerId = data_[@"owner"];
    self.groupId = data_[@"group"];
    self.type = data_[@"type"];
    self.title = data_[@"title"];
    self.latitude = data_[@"lat"];

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if([self stringIsLatLng:data_[@"lat"]] && [self stringIsLatLng:data_[@"lng"]])
    {
        self.latitude = [formatter numberFromString:data_[@"lat"]];
        self.longitude = [formatter numberFromString:data_[@"lng"]];
    }

    self.text = data_[@"text"];
    self.city = data_[@"city"];
    self.region = data_[@"region"];
    self.country = data_[@"country"];
    self.tags = [self valueOrNil:data_[@"picasaTags"]];
    self.created = data_[@"created"];
    
    return true;
}

- (bool)stringIsLatLng:(NSString *)aString
{
    if (! [aString isKindOfClass:[NSString class]])
        return NO;
    
    NSString *pattern = @"^([+-]?(((\\d+(\\.)?)|(\\d*\\.\\d+))([eE][+-]?\\d+)?))$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSTextCheckingResult *match = [regex firstMatchInString:aString
                                                    options:0
                                                      range:NSMakeRange(0, [aString length])];

    return match ? YES : NO;
}

- (id)valueOrNil:(NSString *)value
{
    if (value)
    {
        if([value isKindOfClass:[NSNull class]])
            return nil;
        else
            return value;
    }

    return nil;
}

- (User *)owner
{
    return [[User alloc] initWithId:self.ownerId];
}

- (Group *)group
{
    return [[Group alloc] initWithId:self.groupId];
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
        if ([self.type isEqualToString:@"story"])
        {
            [dateFormatter setDateFormat:@"dd MMM yyyy"];
        }
        else
        {
            [dateFormatter setDateFormat:@"dd MMM yyyy 'at' HH:mm"];
        }
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

- (BOOL)hasTags
{
    return self.tags && [self.tags length] > 0;
}

- (NSString *)photoUrl
{
    if ([self mainPhotoUrl])
        return [self mainPhotoUrl];
    
    Group *group = [[Group alloc] initWithId:self.groupId];
    NSString *url;
    // If the group has trovebox settings then check the tags for a photo to match this activity
    if ([group hasTrovebox]) {
        if (self.tags && [self.tags length])
        {
            // The tag is set based on the activity id
            // TODO: should return all matches for the tags
            Photo *photo = [[Photo alloc] initWithFirstMatchByTagAndTrovebox:self.tags trovebox:group.trovebox];
            url = photo.medium;
        }
        else
        {
            // The tag is set based on the activity id
            NSString *photoTag = @"underplan-*";
            photoTag = [photoTag stringByReplacingOccurrencesOfString:@"*" withString:self.remoteId];
            Photo *photo = [[Photo alloc] initWithFirstMatchByTagAndTrovebox:photoTag trovebox:group.trovebox];
            
            // TODO: return image size url based on device screen width
            url = photo.medium;
        }
    } else {
        url = @"";
    }
    
    [self setMainPhotoUrl:url];
    
    return url;
}

@end
