//
//  GalleryViewController.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMQuiltViewController.h"
#import "TMQuiltView.h"
#import "ASMediaFocusManager.h"

@interface GalleryViewController : TMQuiltViewController <ASMediasFocusDelegate>

@property (copy, nonatomic) NSString *searchTags;
@property (copy, nonatomic) NSDictionary *group;
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;

@end
