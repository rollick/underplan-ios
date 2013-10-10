//
//  SharedApiClient.m
//  Underplan
//
//  Created by Mark Gallop on 26/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "SharedApiClient.h"

@implementation SharedApiClient

@synthesize client, auth;

#pragma mark Singleton Implementation
static SharedApiClient *sharedObject;

+ (SharedApiClient *)sharedInstance
{
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}

#pragma mark Shared Public Methods
+ (UnderplanApiClient *)getClient
{
    // Ensure we are using the shared instance
    SharedApiClient *shared = [SharedApiClient sharedInstance];
    return shared.client;
}

+ (void) setClient:(UnderplanApiClient *)client
{
    // Ensure we are using the shared instance
    SharedApiClient *shared = [SharedApiClient sharedInstance];
    shared.client = client;
}

+ (GTMOAuth2Authentication *)getAuth
{
    // Ensure we are using the shared instance
    SharedApiClient *shared = [SharedApiClient sharedInstance];
    return shared.auth;
}

+ (void) setAuth:(GTMOAuth2Authentication *)auth
{
    // Ensure we are using the shared instance
    SharedApiClient *shared = [SharedApiClient sharedInstance];
    shared.auth = auth;
}
@end
