//
//  Gallery.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gallery : NSObject
{
	NSMutableArray *_photos;
	NSInteger _numberOfPhotos;
}

@property(nonatomic,readonly) NSInteger numberOfPhotos;
@property(nonatomic,readonly) NSMutableArray *photos;

- (id)initTrovebox:(NSDictionary *)trovebox withTags:(NSString *)tags;
- (id)initTrovebox:(NSDictionary *)trovebox withOptions:(NSDictionary *)options;
- (Boolean)loadNextPage;
- (Boolean)loadNextPageAndAppendResults:(Boolean)append;
- (id)photoAtIndex:(NSInteger)index;

@end