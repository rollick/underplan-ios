//
//  UnderplanAppDelegate.h
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeteorClient;

@interface UnderplanAppDelegate : UIResponder <UIApplicationDelegate> {
    MeteorClient *meteorClient;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) MeteorClient *meteor;

@end
