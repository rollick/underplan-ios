//
//  MeteorModel.h
//  Underplan
//
//  Created by Mark Gallop on 7/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MeteorClient.h>

@interface MeteorModel : NSObject

@property (retain, nonatomic) MeteorClient *meteor;

- (BOOL)processApiData: (NSDictionary *)data_;
- (id)initWithData: (NSDictionary *)data_;
- (id)initWithIdAndMeteorClient: (NSString *)id_ meteor:(MeteorClient *)meteor;
- (id)initWithIdAndCollection: (NSString *)id_ collection:(NSArray *)collection_;

@end