//
//  StoryItemView.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "StoryItemView.h"
#import "BannerView.h"

#import <UIColor+HexString.h>

@implementation StoryItemView

- (void) initView
{
    [super initView];
    
    UITextView *mainText = self.mainText;
    ItemDetailsView *detailsView = self.detailsView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    NSString *format = @"V:|-16-[detailsView]-16-[mainText]-(>=16)-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.contentView addConstraints:constraintsArray];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.mainText attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:130];
    
    [self.contentView addConstraint:constraint];
    
    self.banner = [[BannerView alloc] init];
//    self.upperLine.backgroundColor = [UIColor colorWithHexString:@"#008000"];
    [self.contentView addSubview:self.banner];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int bannerWidth = 50;
    int bannerHeight = 28;
    int bannerOffset = 8;
    
    CGRect bannerRect = CGRectMake(self.frame.size.width - bannerWidth - CELL_BORDER_SIZE, bannerOffset + CELL_BORDER_SIZE, bannerWidth, bannerHeight);
    
    [self.banner setFrame:bannerRect];
}

- (int)cellHeight:(NSString *)text
{
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:self.mainText.font forKey: NSFontAttributeName];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil];
    
    return  16 +
            52 + // self.detailsView.frame.size.height +
            16 +
            rect.size.height + // self.mainText.frame.size.height +
            16;
}

@end
