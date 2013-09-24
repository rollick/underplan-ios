//
//  UnderplanCommentItemCell.m
//  Underplan
//
//  Created by Mark Gallop on 2/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanCommentItemCell.h"
#import "UnderplanUserItemView.h"

#include "Comment.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanCommentItemCell

- (void)initView
{
    [super initView];
    
    self.mainView = [[UnderplanUserItemView alloc] init];
    [self.containerView addSubview:self.mainView];
    
    NSDictionary *viewsDictionary = @{@"mainText": self.mainView.mainText, @"detailsView": self.mainView.detailsView};
    
    NSString *format = @"V:|-16-[detailsView]-16-[mainText]-(>=16)-|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                              options:NSLayoutFormatAlignAllLeft
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
}

- (void)loadComment:(Comment *)comment
{
    // Fetch owner and id for cell
    self.itemId = comment.remoteId;
    User *owner = [[User alloc] initWithId:comment.ownerId];
    
    // Set the owners name as the title
    self.mainView.detailsView.title.text = owner.profile[@"name"];
    self.mainView.detailsView.subTitle.text = [comment summaryInfo];
    self.mainView.mainText.text = comment.text;
    
    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [self.mainView.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    self.loaded = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.mainView setFrame:CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height)];
}

- (int)cellHeight:(NSString *)text
{
    if (!text)
        text = @"";
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:self.mainView.mainText.font forKey:NSFontAttributeName];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:[NSDictionary dictionaryWithObject:self.mainView.mainText.font forKey:NSFontAttributeName]];
    
    CGFloat fontSize = self.mainView.mainText.font.pointSize;

    CGRect screenRect = CGRectInset([[UIScreen mainScreen] bounds], 21, 21);
    CGFloat screenWidth = screenRect.size.width;
    CGRect rect;
    float height;
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        rect = [string boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           context:nil];
    } else {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:stringAttributes];
        
        rect = [attributedText boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin context:nil];
    }
    
    height = rect.size.height < fontSize ? fontSize : rect.size.height;
    
    return  BOTTOM_BORDER_SIZE + CELL_BORDER_SIZE +
            16 +
            52 + // self.detailsView.frame.size.height +
            16 +
            height + // self.mainText.frame.size.height +
            16 +
            BOTTOM_BORDER_SIZE + CELL_BORDER_SIZE;
}

@end
