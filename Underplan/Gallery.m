//
//  Gallery.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "Gallery.h"
#import "SBJson.h"

@implementation Gallery

- (NSArray *)searchTrovebox:(NSDictionary *)trovebox withTags:(NSString *)tags
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // Generate URL for searching tags
    NSString *tagUrl = @"https://<domain>/photos/album-<album>/token-<albumKey>/list.json?returnSizes=<returnSizes>,<widthSize>x<widthSize>";
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<domain>" withString:trovebox[@"domain"]];
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<album>" withString:trovebox[@"album"]];
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<albumKey>" withString:trovebox[@"albumKey"]];
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<returnSizes>" withString:@"64x64,320x320,640x640,1024x1024,1600x1600"];
    
    if (tags) {
        tagUrl = [tagUrl stringByAppendingString:[[NSString alloc] initWithFormat:@"&tags=%@",tags]];
    }

    // Get size to match screen width
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    tagUrl = [tagUrl stringByReplacingOccurrencesOfString:@"<widthSize>" withString:[NSString stringWithFormat: @"%.f", screenWidth]];
    
    // Fetch and parse tag search api results
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:tagUrl]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [parser objectWithString:json_string error:nil];
    NSInteger code = [(NSNumber *)[dict objectForKey:@"code"] integerValue];
    NSArray *photos = dict[@"result"];
    
    return photos;
}

@end
