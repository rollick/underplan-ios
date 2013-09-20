//
//  StoryItemView.h
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanUserItemView.h"
#import "BannerView.h"

typedef enum StoryStyle {
    StoryStyleLong,
    StoryStyleShort,
} StoryStyle;

@interface UnderplanStoryView : UnderplanUserItemView
{
    StoryStyle style;
}

@property (retain, nonatomic) BannerView *banner;
@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UILabel *continueLabel;

- (id)initWithStyle:(StoryStyle)aStyle;

@end
