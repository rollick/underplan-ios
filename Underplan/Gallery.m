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
{
    NSDictionary *_trovebox;
    NSInteger _page;
    NSString *_tags;
}

@synthesize photos = _photos;
@synthesize numberOfPhotos = _numberOfPhotos;

// options: tags, pageSize, page
- (id)initTrovebox:(NSDictionary *)trovebox withOptions:(NSDictionary *)options
{
    if (options) {
        _tags = options[@"tags"];
        _page = [options[@"page"] integerValue];
    }
    _trovebox = trovebox;
    
    return [self initWithPhotos:[self fetchResultsByPage:_page andTags:_tags]];
}

- (NSArray *)fetchResults
{
    return [self fetchResultsByPage:1 andTags:@""];
}

- (NSArray *)fetchResultsBy:(NSInteger)page
{
    return [self fetchResultsByPage:page andTags:@""];
}

- (NSArray *)fetchResultsByPage:(NSInteger)page andTags:(NSString *)tags
{
    // Generate URL for searching tags
    NSString *url = @"https://<domain>/photos/album-<album>/token-<albumKey>/list.json?returnSizes=<returnSizes>,<widthSize>x<widthSize>";
    url = [url stringByReplacingOccurrencesOfString:@"<domain>" withString:_trovebox[@"domain"]];
    url = [url stringByReplacingOccurrencesOfString:@"<album>" withString:_trovebox[@"album"]];
    url = [url stringByReplacingOccurrencesOfString:@"<albumKey>" withString:_trovebox[@"albumKey"]];
    url = [url stringByReplacingOccurrencesOfString:@"<returnSizes>" withString:@"180x180,320x320,640x640,960x960,1024x1024,1600x1600"];
    
    if (tags && ![tags isKindOfClass:[NSNull class]] && ![tags isEqualToString:@"-1"])
        url = [url stringByAppendingString:[[NSString alloc] initWithFormat:@"&tags=%@",tags]];
    
    if (page)
        url = [url stringByAppendingString:[[NSString alloc] initWithFormat:@"&page=%ld",(long)page]];
    
    // Get size to match screen width
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    url = [url stringByReplacingOccurrencesOfString:@"<widthSize>" withString:[NSString stringWithFormat: @"%.f", screenWidth]];
    
    NSArray *response = [self sendRequest:url];
    
    return response;
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
    
    return [self initTrovebox:trovebox withOptions:options];
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
		_photos = [photos mutableCopy];
		_numberOfPhotos = [_photos count];
	}
	return self;
}

- (id)photoAtIndex:(NSInteger)index
{
    return [[Photo alloc] initWithData:[_photos objectAtIndex:index]];
}

// Returns true if no more photos
- (Boolean)loadNextPageAndAppendResults:(Boolean)append
{
    // FIXME:   Bit hacky I think to create new gallery instance here jist to fetch
    //          more images
    _page += 1;
    NSArray *newResults = [self fetchResultsByPage:_page andTags:_tags];
    
    if (append)
    {
        [_photos addObjectsFromArray:newResults];
    } else
    {
        _photos = [newResults mutableCopy];
    }
    _numberOfPhotos = [_photos count];
    
    // TODO: 30 is the default pageSize for Trovebox but this should be
    //       defined in the class / instance and used here
    return [newResults count] < 30;
}

- (Boolean)loadNextPage
{
    return [self loadNextPageAndAppendResults:YES];
}

@end
