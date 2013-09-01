//
//  Gallery.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gallery : NSArray

- (NSArray *)searchTrovebox:(NSDictionary *)trovebox withTags:(NSString *)tags;

@end
