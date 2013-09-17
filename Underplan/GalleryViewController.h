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
#import "UnderplanGalleryDelegate.h"

#import "Activity.h"
#import "Group.h"
#import "Gallery.h"

@interface GalleryViewController : TMQuiltViewController <UIPopoverControllerDelegate, UnderplanGalleryDelegate>

@property (retain, nonatomic) UIPopoverController *aPopoverController;
@property (copy, nonatomic) NSString *searchTags;
@property (retain, nonatomic) Gallery *gallery;
//@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
@property (assign, nonatomic) id delegate;

@end
