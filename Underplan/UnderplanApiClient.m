//
//  UnderplanApiClient.m
//  Underplan
//
//  Created by Mark Gallop on 23/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanApiClient.h"
#import "BSONIdGenerator.h"
#import <SocketRocket/SRWebSocket.h>

@implementation UnderplanApiClient

- (void)didCloseWithCode:(NSInteger)code {
    [super didCloseWithCode:code];
    
    //    SR_CLOSING      = 2,
    //    SR_CLOSED       = 3,
    NSNumber *state;
    NSArray *states = @[@2, @3];
    
    for (state in states) {
        if ([[NSNumber numberWithInt:self.ddp.webSocket.readyState] isEqualToNumber:state]) {
            NSLog(@"Reconnecting to Meteor Server");
            [self resetCollections];
            [self.ddp connectWebSocket];
            
            break;
        }
    }
}

@end
