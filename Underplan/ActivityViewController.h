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
#import "ItemDetailsView.h"

@interface ActivityViewController : UnderplanViewController <UIScrollViewDelegate>

@property (retain, nonatomic) ItemDetailsView *detailsView;
@property (retain, nonatomic) UITextView *mainText;
@property (retain, nonatomic) UIImageView *contentImage;
@property (retain, nonatomic) UIView *view;

@property (copy, nonatomic) NSDictionary *activity;

@end
