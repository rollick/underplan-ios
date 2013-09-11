//
//  Photo.m
//  Underplan
//
//  Created by Mark Gallop on 7/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "Photo.h"
#import "Gallery.h"

@implementation Photo

- (id)initWithFirstMatchByTagAndTrovebox:(NSString *)tags trovebox:(NSDictionary *)trovebox
{
    self = [super init];
    Gallery *gallery = [[Gallery alloc] initTrovebox:trovebox withTags:tags];
    
    if([gallery numberOfPhotos]) {
        [self loadData:[gallery photos][0]];
    }

    return self;
}

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    [self loadData:data];
    
    return self;
}

-(void)loadData:(NSDictionary *)data
{
    // Get size to match screen width
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    self.small= data[@"path320x320"];
    self.medium = data[@"path640x640"];
    self.large = data[@"path1024x1024"];
    self.xlarge = data[@"path1600x1600"];
    self.fitWidth = data[[NSString stringWithFormat: @"path%.fx%.f", screenWidth, screenWidth]];
}

@end
