//
//  UIColor+Underplan.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UIColor+Underplan.h"

#import <UIColor+HexString.h>

@implementation UIColor (Underplan)

+ (UIColor *)underplanBgColor {
    return [UIColor colorWithHexString:@"E5E5E5"];
}

+ (UIColor *)underplanPanelColor {
    return [UIColor colorWithHexString:@"#E0E0E0"];
}

+ (UIColor *)underplanPrimaryColor {
    return [UIColor colorWithHexString:@"#008000"];
}

+ (UIColor *)underplanNoticeColor {
    return [UIColor colorWithHexString:@"#1F4100"];
}

+ (UIColor *)underplanPrimaryDarkColor {
    return [UIColor colorWithHexString:@"#D82A1A"];
}

+ (UIColor *)underplanDarkMenuColor {
    return [UIColor colorWithHexString:@"#111111"];
}

+ (UIColor *)underplanDarkMenuFontColor {
    return [UIColor colorWithHexString:@"#FFFFFF"];
}

@end