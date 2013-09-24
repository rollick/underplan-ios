//
//  MeteorModel.h
//  Underplan
//
//  Created by Mark Gallop on 7/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnderplanApiClient.h"

@interface MeteorModel : NSObject

@property (strong, nonatomic) NSString *ownerId;
@property (assign, nonatomic) NSString *remoteId;
@property (retain, nonatomic) UnderplanApiClient *apiClient;

- (void)reload;
- (BOOL)processApiData: (NSDictionary *)data_;
- (id)initWithData: (NSDictionary *)data_;
- (id)initWithId: (NSString *)id_;
- (id)initWithIdAndCollection: (NSString *)id_ collection:(NSArray *)collection_;

@end