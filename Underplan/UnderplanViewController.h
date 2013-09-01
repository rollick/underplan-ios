//
//  UnderplanViewController.h
//  Underplan
//
//  Created by Mark Gallop on 10/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderplanViewController : UIViewController
{
    @protected __weak UIScrollView *_scroller;
    CGFloat _scrollViewContentOffsetYThreshold;
}

- (void)scrollViewDidScroll:(UIScrollView*)aScrollView;
- (void)resetNavigationBarPosition;

@end
