//
//  Gallery.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "Gallery.h"
#import "Photo.h"
#import "SBJson.h"

@implementation Gallery

@synthesize photos=_photos;
@synthesize numberOfPhotos=_numberOfPhotos;

// options: tags, pageSize, page
- (Gallery *)searchTrovebox:(NSDictionary *)trovebox withOptions:(NSDictionary *)options
{
    NSString *tags;
    if (options) {
        tags = options[@"tags"];
    }
    
    // Generate URL for searching tags
    NSString *url = @"https://<domain>/photos/album-<album>/token-<albumKey>/list.json?returnSizes=<returnSizes>,<widthSize>x<widthSize>";
    url = [url stringByReplacingOccurrencesOfString:@"<domain>" withString:trovebox[@"domain"]];
    url = [url stringByReplacingOccurrencesOfString:@"<album>" withString:trovebox[@"album"]];
    url = [url stringByReplacingOccurrencesOfString:@"<albumKey>" withString:trovebox[@"albumKey"]];
    url = [url stringByReplacingOccurrencesOfString:@"<albumKey>" withString:trovebox[@"albumKey"]];
    url = [url stringByReplacingOccurrencesOfString:@"<returnSizes>" withString:@"64x64,320x320,640x640,1024x1024,1600x1600"];
    
    if (tags) {
        url = [url stringByAppendingString:[[NSString alloc] initWithFormat:@"&tags=%@",tags]];
    }
    
    // Get size to match screen width
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    url = [url stringByReplacingOccurrencesOfString:@"<widthSize>" withString:[NSString stringWithFormat: @"%.f", screenWidth]];
    
    NSArray *response = [self sendRequest:url];
    
    return [self initWithPhotos:response];
}


- (Gallery *)initTrovebox:(NSDictionary *)trovebox withTags:(NSString *)tags
{
    NSDictionary *options;
    if (tags) {
        options = @{@"tags": tags};
    }
    
    if ([trovebox[@"album"] isEqualToString:@""] ||
        [trovebox[@"albumKey"] isEqualToString:@""] ||
        [trovebox[@"domain"] isEqualToString:@""])
    {
        return [self init];
    }
    
    return [self searchTrovebox:trovebox withOptions:options];
}

- (NSArray *)sendRequest:(NSString *)url
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // Fetch and parse tag search api results
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [parser objectWithString:json_string error:nil];
//    NSInteger code = [(NSNumber *)[dict objectForKey:@"code"] integerValue];
    NSArray *photos = dict[@"result"];
    
    return photos;
}

- (id)initWithPhotos:(NSArray*)photos
{
	if (self = [super init]) {
		_photos = photos;
		_numberOfPhotos = [_photos count];
	}
	return self;
}

- (id)photoAtIndex:(NSInteger)index
{
    return [[Photo alloc] initWithData:[_photos objectAtIndex:index]];
}

@end
