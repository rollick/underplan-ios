//
//  UnderplanBasicLabel.h
//  Underplan
//
//  Created by Mark Gallop on 19/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderplanBasicLabel : UILabel

+ (id)addTo:(UIView *)aView text:(NSString *)someText;
+ (void)removeFrom:(UIView *)aView;

@end
