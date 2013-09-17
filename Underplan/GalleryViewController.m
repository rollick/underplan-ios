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
#import "UIViewController+ShowHideBars.h"
#import "SharedApiClient.h"

#import "GalleryViewCell.h"
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
    
    [self createGallery];
    
    // Fix the scrollview being behind tabbar
    if (self.tabBarController) {
        UIEdgeInsets inset = self.quiltView.contentInset;
        inset.bottom = self.tabBarController.tabBar.frame.size.height;
        self.quiltView.contentInset = inset;
    }
    
    if (self.navigationController) {
        UIEdgeInsets inset = self.quiltView.contentInset;
        inset.top = self.navigationController.navigationBar.frame.size.height + 20.0f; // 20.0f for the status bar
        self.quiltView.contentInset = inset;
        
        CGPoint topOffset = CGPointMake(0, -inset.top);
        [self.quiltView setContentOffset:topOffset animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showBars];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.quiltView setHidden:NO];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.tabBarController.tabBar setBarStyle:UIBarStyleBlack];
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.tabBarController.tabBar setBarStyle:UIBarStyleDefault];
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor underplanPrimaryColor]];
    }
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
    self.quiltView.delegate = nil;
    
    [self removeObserver:self forKeyPath:@"loading"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QuiltViewControllerDataSource

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

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.quiltView reloadData];
            [self setLoading:NO];
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.quiltView reloadData];
            [self setLoading:NO];
            complete = allPhotosLoaded;
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
    return [self.gallery.photos objectAtIndex:i][@"path1024x1024"];
}

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return self.gallery.numberOfPhotos;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self showBars];
    
    // If last section is about to be shown...
    if(scrollView.contentOffset.y < 0){
        //it means table view is pulled down like refresh
        //NSLog(@"refresh!");
    }
    else if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height))
    {
        [self loadNextPage];
    }
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [self showBars];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [self hideBars];
//}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
	UnderplanSlideshowController *photoController = [[UnderplanSlideshowController alloc] initWithDelegate:self index:[[NSNumber alloc] initWithUnsignedInteger:indexPath.row]];

    [self hideBars];
    [self.quiltView setHidden:YES];
    [self.navigationController pushViewController:photoController animated:YES];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryViewCell *cell = (GalleryViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[GalleryViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    
    Photo *photo = [_gallery photoAtIndex:indexPath.row];
    
    cell.photoView.tag = indexPath.row + 1;
    [cell.photoView setImageWithURL:[NSURL URLWithString:photo.small]
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              if (error){
//                                  PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Couldn't download the image",nil) duration:5000];
//                                  [alert showAlert];
                              } else {
                              }
                          }];
    if ([photo.title isEqualToString:@""])
    {
        [cell.titleLabel setHidden:YES];
    } else
    {
        [cell.titleLabel setHidden:NO];
        cell.titleLabel.text = photo.title;
    }

    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
//    return [self imageUrlAtIndexPath:indexPath].size.height / [self quiltViewNumberOfColumns:quiltView];
    return 96;
}

@end
