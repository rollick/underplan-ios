//
//  UnderplanStoryItemCell.m
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanStoryItemCell.h"

#import "UnderplanStoryView.h"

@implementation UnderplanStoryItemCell

- (void)initView
{
    [super initView];
    
    self.mainView = [[UnderplanStoryView alloc] init];
    self.contentImage = self.mainView.contentImage;
    self.detailsView = self.mainView.detailsView;
    self.mainText = self.mainView.mainText;
        
    [self.contentView addSubview:self.mainView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.mainView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 12)];
}

- (int)cellHeight:(NSString *)text
{
    NSString *previewText = text;
    if ([text length] > 250)
     previewText = [text substringToIndex:250];
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:self.mainText.font forKey: NSFontAttributeName];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float height;
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil];
        
        height = rect.size.height < 50 ? 50 : rect.size.height;
    } else {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:stringAttributes];
        
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        height = rect.size.height < 50 ? 50 : rect.size.height;
    }
    
    return  16 +
            52 + // self.detailsView.frame.size.height +
            16 +
            height + // self.mainText.frame.size.height +
            50 +
            16; // border
}

@end
