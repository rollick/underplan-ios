//
//  SharedApiClient.h
//  Underplan
//
//  Created by Mark Gallop on 26/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UnderplanApiClient.h"
#import "GTMOAuth2Authentication.h"

@interface SharedApiClient : NSObject {
    UnderplanApiClient *client;
    GTMOAuth2Authentication *auth;
}

@property (nonatomic, retain) UnderplanApiClient *client;
@property (nonatomic, retain) GTMOAuth2Authentication *auth;

+ (SharedApiClient *) sharedInstance;
+ (UnderplanApiClient *) getClient;
+ (void) setClient:(UnderplanApiClient *)client;
+ (GTMOAuth2Authentication *) getAuth;
+ (void) setAuth:(GTMOAuth2Authentication *)auth;

@end
