//
//  Photo.h
//  Underplan
//
//  Created by Mark Gallop on 7/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (copy, nonatomic) NSString *small;
@property (copy, nonatomic) NSString *medium;
@property (copy, nonatomic) NSString *large;

- (id)intWithFirstMatchByTagAndTrovebox:(NSString *)tags trovebox:(NSDictionary *)trovebox;

@end
