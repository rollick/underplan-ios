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
	NSArray *_photos;
	NSInteger _numberOfPhotos;
}

@property(nonatomic,readonly) NSInteger numberOfPhotos;
@property(nonatomic,readonly) NSArray *photos;

- (id)initTrovebox:(NSDictionary *)trovebox withTags:(NSString *)tags;

@end