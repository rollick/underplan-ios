//
//  UnderplanViewController.m
//  Underplan
//
//  Created by Mark Gallop on 10/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanViewController.h"
#import "UIViewController+UnderplanApiNotifications.h"
#import "UIViewController+BarColor.h"

#import "UnderplanApiClient.h"
#import "UIColor+Underplan.h"

#import <QuartzCore/QuartzCore.h>

#define kNavBarDefaultPosition CGPointMake(160, 42)

@interface UnderplanViewController ()

@end

@implementation UnderplanViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self configureStandardApiNotifications];
    [self resetNavigationBarPosition];
    [self setDefaultBarColor];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self clearApiNotifications];
}

// if your subclasses have scrollviews, and you want the navigation bar to only
// be present when you are at the top, you can call this method in your scrollViewDelegate.
- (void)scrollViewDidScroll:(UIScrollView*)aScrollView
{
//    if(_scroller == aScrollView)
//    {
//        [self updateNavigatioBarVisibility:aScrollView];
//    }
}

- (void)updateNavigatioBarVisibility:(UIScrollView*)aScrollView
{
    CALayer *layer = self.navigationController.navigationBar.layer;
    
    CGFloat contentOffsetY = aScrollView.contentOffset.y;
    
    if (contentOffsetY > _scrollViewContentOffsetYThreshold) {
//        self.navigationController.toolbar.translucent = YES;
//        self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 20.0, 0.0);
//
//        _scroller.contentInset = contentInsets;
//        _scroller.scrollIndicatorInsets = contentInsets;
//[_scroller setContentOffset:CGPointMake(0,0) animated:YES];
        
        layer.position = CGPointMake(layer.position.x,
                                     42 - MIN((contentOffsetY - _scrollViewContentOffsetYThreshold), 48.0));
    }
    else
    {
        // then don't do any of this fancy scrolling stuff
        layer.position = kNavBarDefaultPosition;
    }
}

- (void)resetNavigationBarPosition
{
    CALayer *layer = self.navigationController.navigationBar.layer;
    layer.position = kNavBarDefaultPosition;
}

@end
