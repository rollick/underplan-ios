//
//  Photo.m
//  Underplan
//
//  Created by Mark Gallop on 7/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "Photo.h"

#import "SBJson.h"

@implementation Photo

- (id)intWithFirstMatchByTagAndTrovebox:(NSString *)tags trovebox:(NSDictionary *)trovebox
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // Generate URL for searching tags
    NSString *tagUrl = @"https://<domain>/photos/album-<album>/token-<albumKey>/list.json?tags=<tags>&returnSizes=<returnSizes>";
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<domain>" withString:trovebox[@"domain"]];
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<album>" withString:trovebox[@"album"]];
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<albumKey>" withString:trovebox[@"albumKey"]];
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<tags>" withString:tags];
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<returnSizes>" withString:@"72x72,104x104,320x320,640x640,1024x1024,1600x1600"];
    
    // Fetch and parse tag search api results
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:tagUrl]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [parser objectWithString:json_string error:nil];
    NSInteger code = [(NSNumber *)[dict objectForKey:@"code"] integerValue];
    NSArray *photos = dict[@"result"];
    
    if (code == 200 && [photos count]) {
        self.small= photos[0][@"path320x320"];
        self.medium = photos[0][@"path1024x1024"];
        self.large = photos[0][@"path1600x1600"];
    }

    return self;
}

@end
