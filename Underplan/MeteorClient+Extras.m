//
//  MeteorClient+Extras.m
//  Underplan
//
//  Created by Mark Gallop on 20/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "MeteorClient+Extras.h"
#import "BSONIdGenerator.h"

@implementation MeteorClient (DDPExtras)

- (void)addSubscriptionWithParameters:(NSString *)subscriptionName paramaters:(NSArray *)parameters {
    [self.subscriptions setObject:[NSArray array]
                           forKey:subscriptionName];
    NSString *uid = [[BSONIdGenerator generate] substringToIndex:15];
    [self.ddp subscribeWith:uid name:subscriptionName parameters:parameters];
}

@end
