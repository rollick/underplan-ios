//
//  UnderplanCommentItemCell.m
//  Underplan
//
//  Created by Mark Gallop on 2/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanCommentItemCell.h"

#import "UnderplanUserItemView.h"

@implementation UnderplanCommentItemCell

- (void)initView
{
    [super initView];
    
    self.mainView = [[UnderplanUserItemView alloc] init];
    self.contentImage = self.mainView.contentImage;
    self.detailsView = self.mainView.detailsView;
    self.mainText = self.mainView.mainText;

    [self.contentView addSubview:self.mainView];
    
    UITextView *mainText = self.mainText;
    UnderplanItemDetailsView *detailsView = self.detailsView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    NSString *format = @"V:|-16-[detailsView]-16-[mainText]-(>=16)-|";
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                              options:NSLayoutFormatAlignAllLeft
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.mainView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - BOTTOM_BORDER_SIZE - BOTTOM_BORDER_PADDING)];
}

- (int)cellHeight:(NSString *)text
{
    if (!text)
        text = @"";
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:self.mainText.font forKey: NSFontAttributeName];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGRect rect;
    float height;
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        rect = [text boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil];
    } else {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:stringAttributes];
        
        rect = [attributedText boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin context:nil];
    }
    
    height = rect.size.height < 50 ? 50 : rect.size.height;
    
    return  16 +
            52 + // self.detailsView.frame.size.height +
            16 +
            height + // self.mainText.frame.size.height +
            24 + // fudge!
            16 + 
            BOTTOM_BORDER_PADDING + // border
            BOTTOM_BORDER_SIZE;
}

@end
