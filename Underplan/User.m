//
//  User.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize _id;
@synthesize admin;
@synthesize services;
@synthesize profile;

- (id)initWithData: (NSDictionary *)data_
{
    self = [super init];
    
    self._id = data_[@"_id"];
    self.admin = data_[@"admin"];
    self.profile = data_[@"profile"];
    self.services = data_[@"services"];
    
    return self;
}

- (id)initWithCollectionAndId: (NSMutableArray *)collection_ id:(NSString *)id_
{
    self = [super init];
    
    NSUInteger count = 0;
    for (NSDictionary *dict in collection_) {
        NSString *mod = dict[@"_id"];
        if ([mod isEqualToString:id_]) {
            break;
        }
        count++;
    }
    
    NSDictionary *data_ = collection_[count];
    
    self._id = data_[@"_id"];
    self.admin = data_[@"admin"];
    self.profile = data_[@"profile"];
    self.services = data_[@"services"];
    
    return self;
}

- (NSString *)profileImageUrl:(NSNumber *)size
{
    // Set the owners profile picture
    NSString *imageUrl = [[NSString alloc] initWithString:self.profile[@"picture"]];
    
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
}

@end