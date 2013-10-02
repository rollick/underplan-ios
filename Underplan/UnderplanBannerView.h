//
//  BannerView.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderplanBannerView : UIView

@property (retain, nonatomic) UIView *border;
@property (retain, nonatomic) UILabel *label;
@property (retain, nonatomic) NSString *text;
@property (nonatomic) NSInteger bannerBorder;

@end
