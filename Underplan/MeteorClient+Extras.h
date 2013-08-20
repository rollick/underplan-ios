//
//  MeteorClient+Extras.h
//  Underplan
//
//  Created by Mark Gallop on 20/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "MeteorClient.h"

@interface MeteorClient (Extras)

- (void)addSubscriptionWithParameters:(NSString *)subscriptionName paramaters:(NSArray *)parameters;

@end
