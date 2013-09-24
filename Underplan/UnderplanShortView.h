//
//  ShortItemView.h
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanUserItemView.h"

typedef enum ShortStyle {
    ShortStyleDefault,
    ShortStyleWithImage,
} ShortStyle;

@interface UnderplanShortView : UnderplanUserItemView
{
    ShortStyle style;
}

- (id)initWithStyle:(ShortStyle)aStyle;

@end
