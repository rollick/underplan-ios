//
//  GalleryViewController.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GalleryViewController.h"
#import "UnderplanSlideshowController.h"
#import "MosaicLayout.h"
#import "MosaicData.h"
#import "MosaicCell.h"

#import "UnderplanBasicLabel.h"

#import "UIViewController+ShowHideBars.h"
#import "UIViewController+BarColor.h"

#import "SharedApiClient.h"

#import "Gallery.h"
#import "Photo.h"

#import "UIColor+Underplan.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface GalleryViewController ()

@property (retain, nonatomic) Activity *activity;
@property (retain, nonatomic) Group *group;
@property BOOL loading;

@end

#define kDoubleColumnProbability 40

@implementation GalleryViewController {
    BOOL forceReload;
    BOOL complete;
}

static void * const GalleryKVOContext = (void*)&GalleryKVOContext;

@synthesize gallery = _gallery, group = _group, activity = _activity, loading;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self addObserver:self
               forKeyPath:@"loading"
                  options:NSKeyValueObservingOptionNew
                  context:GalleryKVOContext];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([_delegate respondsToSelector:@selector(activity)])
        [self setActivity:[_delegate activity]];

    if ([_delegate respondsToSelector:@selector(group)])
        [self setGroup:[_delegate group]];
    
    _collectionViewLayout = [[MosaicLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:_collectionViewLayout];

    [_collectionView registerClass:[MosaicCell class] forCellWithReuseIdentifier:@"cell"];
    
    [(MosaicLayout *)_collectionView.collectionViewLayout setDelegate:self];
    
    _galleryDataSource = [[GalleryDataSource alloc] init];
    _collectionView.dataSource = _galleryDataSource;
    _collectionView.delegate = self;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = YES;
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barStyle)])
    {
        // Fix the scrollview being behind tabbar
        if (self.tabBarController) {
            UIEdgeInsets inset = self.collectionView.contentInset;
            inset.bottom = self.tabBarController.tabBar.frame.size.height;
            self.collectionView.contentInset = inset;
        }
        
        if (self.navigationController) {
            UIEdgeInsets inset = self.collectionView.contentInset;
            inset.top = self.navigationController.navigationBar.frame.size.height + 20.0f; // 20.0f for the status bar
            self.collectionView.contentInset = inset;
            
            CGPoint topOffset = CGPointMake(0, -inset.top);
            [self.collectionView setContentOffset:topOffset animated:YES];
        }
    }
    
    [self.view addSubview:_collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showBars];
    [self setDarkBarColor];
    
    // FIXME: ugly but need to ensure the tab / nav bars have animated into place
    if (_gallery == nil)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(createGallery)
                                                    userInfo:nil
                                                    repeats:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"loading"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:@1]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        }
    }
}

-(void)dealloc
{
    // FIXME:   this is a temp fix for a
    //              scrollViewDidScroll: message sent to deallocated instance
    //          issue with ios7
    _collectionView.delegate = nil;
    
    [self removeObserver:self forKeyPath:@"loading"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createGallery
{
    [self setLoading:YES];
    
    if (_activity && _activity.tags)
        _searchTags = _activity.tags;
    else
        _searchTags = @"-1"; // FIXME: need a better way to indicate no searchTags
    
    NSDictionary *options = @{@"tags" : _searchTags, @"page" : @"1"};
    
    dispatch_queue_t troveQueue = dispatch_queue_create("Trovebox Request Queue", NULL);
    dispatch_async(troveQueue, ^{
        _gallery = [[Gallery alloc] initTrovebox:_group.trovebox withOptions:options];
        NSMutableArray *indexPath = [_galleryDataSource loadGalleryData:_gallery];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setLoading:NO];
            
            if ([indexPath count] > 0)
            {
                [UnderplanBasicLabel removeFrom:self.view];
                [_collectionView insertItemsAtIndexPaths:indexPath];
            }
            else
            {
                [UnderplanBasicLabel addTo:self.view text:@"No Photos"];
            }
            
        });
    });
}

- (void)loadNextPage
{
    if (loading || complete)
        return;
    
    [self setLoading:YES];
    
    dispatch_queue_t troveQueue = dispatch_queue_create("Trovebox Request Queue", NULL);
    dispatch_async(troveQueue, ^{
        Boolean allPhotosLoaded = [_gallery loadNextPage];
        
        NSMutableArray *indexPath = [_galleryDataSource loadGalleryData:_gallery];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setLoading:NO];
            complete = allPhotosLoaded;

            [_collectionView insertItemsAtIndexPaths:indexPath];
        });
    });
}

#pragma mark - UnderplanGalleryDelegate

- (int)numberOfPhotos
{
    return self.gallery.numberOfPhotos;;
}

- (NSString *)imageUrlAtIndexPath:(NSIndexPath *)indexPath {
    return [self.gallery.photos objectAtIndex:indexPath.row][@"path320x320"];
}

- (NSString *)fullImageUrlAtIndexPath:(NSNumber *)index {
    int i = [index intValue];
    return [self.gallery.photos objectAtIndex:i][@"path960x960"];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    MosaicLayout *layout = (MosaicLayout *)_collectionView.collectionViewLayout;
    [layout invalidateLayout];
}

#pragma mark - MosaicLayoutDelegate

-(float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;
    
    MosaicData *aMosaicModule = [_galleryDataSource.elements objectAtIndex:indexPath.row];
    
    if (aMosaicModule.relativeHeight != 0){
        
        //  If the relative height was set before, return it
        retVal = aMosaicModule.relativeHeight;
        
    }else{
        
        BOOL isDoubleColumn = [self collectionView:collectionView isDoubleColumnAtIndexPath:indexPath];
        if (isDoubleColumn){
            //  Base relative height for double layout type. This is 0.75 (height equals to 75% width)
            retVal = 0.75;
        }
        
        /*  Relative height random modifier. The max height of relative height is 25% more than
         *  the base relative height */
        
        float extraRandomHeight = arc4random() % 25;
        retVal = retVal + (extraRandomHeight / 100);
        
        /*  Persist the relative height on MosaicData so the value will be the same every time
         *  the mosaic layout invalidates */
        
        aMosaicModule.relativeHeight = retVal;
    }
    
    return retVal;
}

-(BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath
{
    MosaicData *aMosaicModule = [_galleryDataSource.elements objectAtIndex:indexPath.row];
    
    if (aMosaicModule.layoutType == kMosaicLayoutTypeUndefined){
        
        /*  First layout. We have to decide if the MosaicData should be
         *  double column (if possible) or not. */
        
        NSUInteger random = arc4random() % 100;
        if (random < kDoubleColumnProbability){
            aMosaicModule.layoutType = kMosaicLayoutTypeDouble;
        }else{
            aMosaicModule.layoutType = kMosaicLayoutTypeSingle;
        }
    }
    
    BOOL retVal = aMosaicModule.layoutType == kMosaicLayoutTypeDouble;
    
    return retVal;
    
}

-(NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView
{
    UIInterfaceOrientation anOrientation = self.interfaceOrientation;
    
    //  Set the quantity of columns according of the device and interface orientation
    NSUInteger retVal = 0;
    if (UIInterfaceOrientationIsLandscape(anOrientation)){
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            retVal = kColumnsiPadLandscape;
        }else{
            retVal = kColumnsiPhoneLandscape;
        }
        
    }else{
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            retVal = kColumnsiPadPortrait;
        }else{
            retVal = kColumnsiPhonePortrait;
        }
    }
    
    return retVal;
}


- (void)scrollViewDidScroll:(UIScrollView *)collectionView
{
    // If last section is about to be shown...
    if(collectionView.contentOffset.y < 0){
        //it means table view is pulled down like refresh
        //NSLog(@"refresh!");
//        [self showBars];
    }
    else if (collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.bounds.size.height))
    {
        [self loadNextPage];
    }
    else
    {
//        [self hideBars];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	UnderplanSlideshowController *photoController = [[UnderplanSlideshowController alloc] initWithDelegate:self index:[[NSNumber alloc] initWithUnsignedInteger:indexPath.row]];

//    [self hideBars];
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:photoController animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
                     }];
//    [self.navigationController pushViewController:photoController animated:YES];
}

@end
