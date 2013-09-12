//
//  ActivityViewController.h
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanViewController.h"

#import <UIKit/UIKit.h>
#import "UnderplanApiClient.h"
#import "UnderplanUserItemView.h"
#import "UnderplanGroupAwareDelegate.h"

#import "Activity.h"

@interface ActivityViewController : UnderplanViewController <UIScrollViewDelegate>

@property (retain, nonatomic) UIScrollView *view;
@property (retain, nonatomic) UnderplanUserItemView *mainView;
@property (assign, nonatomic) id <UnderplanGroupAwareDelegate> delegate;

@end
