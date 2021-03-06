//
//  UnderplanAppDelegate.m
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanAppDelegate.h"
#import "MasterViewController.h"
#import "UnderplanApiClient.h"
#import "SharedApiClient.h"

@implementation UnderplanAppDelegate
@synthesize apiClient;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    self.apiClient = [[UnderplanApiClient alloc] init];
    
//    NSArray *params = @[@{@"limit":@10}];
    [self.apiClient addSubscription:@"groups"];
    [self.apiClient addSubscription:@"directory"];
    [self.apiClient addSubscription:@"userDetails"];

    dispatch_queue_t meteorQueue = dispatch_queue_create("Meteor Connect Queue", NULL);
    dispatch_async(meteorQueue, ^{
//        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:@"wss://underplan.it:443/websocket" delegate:self.apiClient];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:@"ws://localhost:3000/websocket" delegate:self.apiClient];
        
        self.apiClient.ddp = ddp;
        [SharedApiClient setClient:self.apiClient];
    });



    
    return YES;
}
						
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.apiClient resetCollections];
    [self.apiClient.ddp connectWebSocket];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
