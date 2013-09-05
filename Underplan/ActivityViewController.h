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

@interface ActivityViewController : UnderplanViewController <UIScrollViewDelegate>

@property (retain, nonatomic) UIScrollView *view;
@property (retain, nonatomic) UnderplanUserItemView *mainView;

@property (copy, nonatomic) NSDictionary *activity;

@end
