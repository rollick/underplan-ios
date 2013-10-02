//
//  UnderplanActivityView.h
//  Underplan
//
//  Created by Mark Gallop on 2/10/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanUserItemView.h"

#import "UnderplanBannerView.h"

typedef enum UnderplanActivityViewStyle {
    ShortStyle,
    ShortStyleWithImage,
    StoryStyleLong,
    StoryStyleShort,
    StoryStyleShortWithImage
} UnderplanActivityViewStyle;

@interface UnderplanActivityView : UnderplanUserItemView
{
    UnderplanActivityViewStyle style;
}

@property (retain, nonatomic) UnderplanBannerView *banner;
@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UILabel *continueLabel;

- (id)initWithStyle:(UnderplanActivityViewStyle)aStyle;

@end
