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

#import "GalleryViewCell.h"
#import "Gallery.h"

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

        _searchTags = @"";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([_delegate respondsToSelector:@selector(activity)])
        _activity = [_delegate activity];

    if ([_delegate respondsToSelector:@selector(group)])
        _group = [_delegate group];
    
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
    
    [self.tabBarController.tabBar setHidden:NO];
    [self.quiltView setHidden:NO];
        
    [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkMenuFontColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor underplanDarkMenuFontColor]];
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
    {
        [self.tabBarController.tabBar setBarTintColor:[UIColor underplanDarkMenuColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor underplanDarkMenuColor]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setTintColor:[UIColor underplanPrimaryColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryColor]];

    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        [self.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
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
    
    NSArray *optionValues = [[NSArray alloc] initWithObjects:_searchTags,@"1",nil];
    NSArray *optionKeys = [[NSArray alloc] initWithObjects:@"tags",@"page",nil];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithObjects:optionValues forKeys:optionKeys];
    
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
    [self setLoading:YES];
    
    dispatch_queue_t troveQueue = dispatch_queue_create("Trovebox Request Queue", NULL);
    dispatch_async(troveQueue, ^{
        [_gallery loadNextPage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.quiltView reloadData];
            [self setLoading:NO];
        });
    });
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
    // If last section is about to be shown...
    if(scrollView.contentOffset.y < 0){
        //it means table view is pulled down like refresh
        //NSLog(@"refresh!");
    }
    else if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height))
    {
        if (! loading && ! complete )
        {
            [self loadNextPage];
        }
    }
    
    if (self.navigationController.navigationBar.hidden)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.tabBarController.tabBar setHidden:NO];
    }
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
	UnderplanSlideshowController *photoController = [[UnderplanSlideshowController alloc] initWithDelegate:self index:[[NSNumber alloc] initWithUnsignedInteger:indexPath.row]];

    [self.quiltView setHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController pushViewController:photoController animated:YES];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryViewCell *cell = (GalleryViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[GalleryViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
//        [self.mediaFocusManager installOnView:cell.photoView];
    }
    
    cell.photoView.tag = indexPath.row + 1;
    [cell.photoView setImageWithURL:[NSURL URLWithString:[self imageUrlAtIndexPath:indexPath]]
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              if (error){
//                                  PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Couldn't download the image",nil) duration:5000];
//                                  [alert showAlert];
                              } else {
                              }
                          }];
    cell.titleLabel.text = nil;
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
