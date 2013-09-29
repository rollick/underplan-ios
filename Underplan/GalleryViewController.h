//
//  GalleryViewController.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MosaicLayoutDelegate.h"

#import "UnderplanGalleryDelegate.h"

#import "UnderplanViewController.h"

#import "Activity.h"
#import "Group.h"
#import "Gallery.h"
#import "GalleryDataSource.h"

#import <MosaicLayout.h>

#define kColumnsiPadLandscape 5
#define kColumnsiPadPortrait 4
#define kColumnsiPhoneLandscape 3
#define kColumnsiPhonePortrait 2

@interface GalleryViewController : UnderplanViewController <UICollectionViewDelegate, MosaicLayoutDelegate, UnderplanGalleryDelegate>

@property (retain, nonatomic) UIPopoverController *aPopoverController;
@property (copy, nonatomic) NSString *searchTags;
@property (retain, nonatomic) Gallery *gallery;
@property (assign, nonatomic) id delegate;
@property (strong, nonatomic) MosaicLayout *collectionViewLayout;
@property (retain, nonatomic) UICollectionView *collectionView;
@property (retain, nonatomic) GalleryDataSource *galleryDataSource;

@end
