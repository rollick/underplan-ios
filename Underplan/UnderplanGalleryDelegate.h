//
//  UnderplanGalleryDelegate.h
//  Underplan
//
//  Created by Mark Gallop on 16/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UnderplanGalleryDelegate <NSObject>

- (NSString *)fullImageUrlAtIndexPath:(NSNumber *)index;
- (int)numberOfPhotos;

@end
