//
//  GalleryViewController.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GalleryViewController.h"

#import "GalleryViewCell.h"
#import "Gallery.h"

#import "UIColor+Underplan.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface GalleryViewController ()

@property (nonatomic, retain) NSArray *images;

@end

@implementation GalleryViewController {
    BOOL loading;
    BOOL complete;
    int limit;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;
    self.mediaFocusManager.isDefocusingWithTap = YES;
    self.mediaFocusManager.elasticAnimation = NO;
    
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
    
    [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkMenuFontColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor underplanDarkMenuFontColor]];
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
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

    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        [self.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
    }
}

-(void)dealloc
{
    // FIXME:   this is a temp fix for a
    //              scrollViewDidScroll: message sent to deallocated instance
    //          issue with ios7
    self.quiltView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QuiltViewControllerDataSource

- (NSArray *)images {
    if (!_images) {
        _images = [[Gallery alloc] searchTrovebox:_group[@"trovebox"] withTags:self.searchTags];
    }
    return _images;
}

- (NSString *)imageUrlAtIndexPath:(NSIndexPath *)indexPath {
    return [self.images objectAtIndex:indexPath.row][@"path320x320"];
}

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [self.images count];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If last section is about to be shown...
//    if(scrollView.contentOffset.y < 0){
//        //it means table view is pulled down like refresh
//        //NSLog(@"refresh!");
//    }
//    else if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height))
//    {
//        if (! loading && ! complete )
//        {
//            loading = YES;
//            limit = limit + 10;
//            
//            NSArray *params = @[@{@"groupId":_group[@"_id"], @"limit":[NSNumber numberWithInt:limit]}];
//            [[SharedApiClient getClient] addSubscription:@"feedActivities" withParamaters:params];
//        }
//    }
    
    if (self.navigationController.navigationBar.hidden)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.tabBarController.tabBar setHidden:NO];
    }
}

//- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (! self.navigationController.navigationBar.hidden)
//    {
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        
//        CATransition *animation = [CATransition animation];
//        [animation setType:kCATransitionFade];
//        [[self.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
//        [self.tabBarController.tabBar setHidden:YES];
//    }
//}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    GalleryViewCell *cell = (GalleryViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[GalleryViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
        [self.mediaFocusManager installOnView:cell.photoView];
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

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
//    return [self imageUrlAtIndexPath:indexPath].size.height / [self quiltViewNumberOfColumns:quiltView];
    return 96;
}

#pragma mark - ASMediaFocusDelegate
- (UIImage *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager imageForView:(UIView *)view
{
    return ((UIImageView *)view).image;
}

- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager finalFrameforView:(UIView *)view
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    return window.bounds;
}

- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager
{
    id rootViewController = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];

    return rootViewController;
}

- (NSURL *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaURLForView:(UIView *)view
{
    NSDictionary *imageData = [self.images objectAtIndex:(view.tag - 1)];
    NSURL *url = [NSURL URLWithString:imageData[@"path1024x1024"]];
    
    return url;
}

- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager titleForView:(UIView *)view;
{
    NSDictionary *imageData = [self.images objectAtIndex:(view.tag - 1)];
    NSString *title = imageData[@"title"];
    
    return title;
}

@end
