//
//  GalleryDataSource.h
//  Underplan
//
//  Created by Mark Gallop on 20/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Gallery.h"

@interface GalleryDataSource : NSObject <UICollectionViewDataSource>

@property (readonly) NSMutableArray *elements;

- (NSMutableArray *)loadGalleryData:(Gallery *)aGallery;

@end
