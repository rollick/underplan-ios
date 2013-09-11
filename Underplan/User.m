//
//  User.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "User.h"

@implementation User

- (NSString *)collectionName
{
    return @"users";
}

- (BOOL)processApiData: (NSDictionary *)data_
{
    self.remoteId = data_[@"_id"];
    self.admin = data_[@"admin"];
    self.profile = data_[@"profile"];
    self.services = data_[@"services"];
    
    return true;
}

- (NSString *)profileImageUrl:(NSNumber *)size
{
    // Set the owners profile picture
    NSString *profileUrl = self.profile[@"picture"];
    
    if (profileUrl) {
        NSString *imageUrl = [[NSString alloc] initWithString:profileUrl];
        
        // The image url needs to be tweaked based on the login service used
        if (self.services[@"google"])
        {
            // Add sz=75 etc to url
            // NOTE: the size should very based on the device...
            imageUrl = [imageUrl stringByAppendingString:@"?sz=144"];
        } else if (self.services[@"facebook"])
        {
            // Add ?width=75 to url
            imageUrl = [imageUrl stringByAppendingString:@"?width=144"];
        }
        
        return imageUrl;
    } else {
        return @"";
    }
}

@end