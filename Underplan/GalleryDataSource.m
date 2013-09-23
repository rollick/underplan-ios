//
//  GalleryDataSource.m
//  Underplan
//
//  Created by Mark Gallop on 20/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "GalleryDataSource.h"
#import "MosaicData.h"
#import "MosaicCell.h"

#import "Gallery.h"
#import "Photo.h"

@interface GalleryDataSource()

@end

@implementation GalleryDataSource

#pragma mark - Public

- (NSMutableArray *)loadGalleryData:(Gallery *)aGallery
{
    // FIXME: terrible shortcut here!! This class and the Gallery class need to work
    //        together the fetch new gallery results sets and append to
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:aGallery.numberOfPhotos];
    int previousCount = [_elements count];
    
    for (NSUInteger i = 0; i < aGallery.numberOfPhotos - previousCount; ++i)
    {
        [indexPaths addObject:[NSIndexPath indexPathForItem:previousCount+i inSection:0]];
        
        Photo *photo = [aGallery photoAtIndex:previousCount+i];
        MosaicData *aMosaicModule = [[MosaicData alloc] initWithDictionary:[photo mosaicData]];
        [_elements addObject:aMosaicModule];
    }
    
    return indexPaths;
}

- (id)init
{
    self = [super init];
    if (self){
        _elements = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_elements count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    MosaicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    MosaicData *data = [_elements objectAtIndex:indexPath.row];
    cell.mosaicData = data;
    
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    cell.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    return cell;
}

@end
