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

+ (UIColor *)underplanGrayTextColor
{
    return [UIColor colorWithHexString:@"CCCCCC"];
}

+ (UIColor *)underplanGroupCellTextColor
{
    return [UIColor underplanGrayTextColor];
}

+ (UIColor *)underplanGroupCellTitleColor
{
    return [UIColor colorWithHexString:@"FFFFFF"];
}

+ (UIColor *)underplanGroupCellColor
{
    return [[UIColor colorWithHexString:@"303030"] colorWithAlphaComponent:0.8f];
}

+ (UIColor *)underplanCellBgColor
{
    return [UIColor colorWithHexString:@"FFFFFF"];
}

+ (UIColor *)underplanBgColor
{
    return [UIColor colorWithHexString:@"E5E5E5"];
}

+ (UIColor *)underplanPanelColor
{
    return [UIColor colorWithHexString:@"#E0E0E0"];
}

+ (UIColor *)underplanPrimaryColor
{
    return [UIColor colorWithHexString:@"#008000"];
}

+ (UIColor *)underplanNoticeColor
{
    return [UIColor colorWithHexString:@"#1F4100"];
}

+ (UIColor *)underplanWarningColor
{
    return [UIColor colorWithHexString:@"#D82A1A"];
}

+ (UIColor *)underplanPrimaryDarkColor
{
    return [UIColor colorWithHexString:@"#004D00"];
}

+ (UIColor *)underplanDarkMenuColor
{
    return [UIColor colorWithHexString:@"#000000"];
}

+ (UIColor *)underplanDarkMenuFontColor
{
    return [UIColor colorWithHexString:@"#FFFFFF"];
}

@end