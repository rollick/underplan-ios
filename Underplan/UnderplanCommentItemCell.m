//
//  UnderplanCommentItemCell.m
//  Underplan
//
//  Created by Mark Gallop on 2/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanCommentItemCell.h"
#import "UnderplanUserItemView.h"
#import "UnderplanViewConstants.h"

#include "Comment.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanCommentItemCell

- (void)initView
{
    [super initView];
    
    self.mainView = [[UnderplanUserItemView alloc] init];
    [self.mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.containerView addSubview:self.mainView];
    
    NSDictionary *viewsDictionary = @{@"mainView": self.mainView, @"mainText": self.mainView.mainText, @"detailsView": self.mainView.detailsView};
    
    NSString *format = @"V:|-(padding)-[detailsView]-(padding)-[mainText]-(padding)-|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:0
                                                                 metrics:@{@"padding": @STANDARD_PADDING}
                                                                   views:viewsDictionary]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllLeft
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllTop
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
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text
                                                                 attributes:[NSDictionary dictionaryWithObject:self.mainView.mainText.font forKey:NSFontAttributeName]];
    
    CGFloat fontSize = self.mainView.mainText.font.pointSize;
    
    CGFloat offset = CELL_BORDER_SIZE + STANDARD_PADDING;
    CGRect screenRect = CGRectInset([[UIScreen mainScreen] bounds], offset, offset);
    CGFloat screenWidth = screenRect.size.width;
    float height;
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(screenWidth, 2000)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                       context:nil];
    
    height = rect.size.height < fontSize+10 ? fontSize+10 : rect.size.height;
    
    return  CELL_PADDING + STANDARD_PADDING +
            52 + // self.detailsView.frame.size.height +
            STANDARD_PADDING +
            height + // self.mainText.frame.size.height +
            STANDARD_PADDING +
            CELL_BORDER_SIZE + CELL_PADDING;
}

@end
