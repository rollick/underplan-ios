//
//  SharedApiClient.h
//  Underplan
//
//  Created by Mark Gallop on 26/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UnderplanApiClient.h"

@interface SharedApiClient : NSObject {
    UnderplanApiClient *client;
}

@property (nonatomic, retain) UnderplanApiClient *client;

+ (SharedApiClient *) sharedInstance;
+ (UnderplanApiClient *) getClient;
+ (void) setClient:(UnderplanApiClient *)client;

@end
