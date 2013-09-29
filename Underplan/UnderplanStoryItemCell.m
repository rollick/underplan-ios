//
//  UnderplanStoryItemCell.m
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanStoryItemCell.h"
#import "UnderplanStoryView.h"
#import "UnderplanViewConstants.h"

#import "User.h"

#import "UIColor+Underplan.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanStoryItemCell

- (void)initView
{
    [super initView];
    
    self.mainView = [[UnderplanStoryView alloc] initWithStyle:StoryStyleShort];
    [self.mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.containerView.layer.backgroundColor = [UIColor brownColor].CGColor;
    
    [self.containerView addSubview:self.mainView];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllLeft
                                                                               metrics:nil
                                                                                 views:@{@"mainView": self.mainView}]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:nil
                                                                                 views:@{@"mainView": self.mainView}]];
}

- (void)loadActivity:(Activity *)activity
{
    [super loadActivity:activity];
    
    // Fetch owner and id for cell
    self.itemId = activity.remoteId;
    User *owner = [[User alloc] initWithId:activity.ownerId];
    
    // Set the owners name as the title
    self.mainView.detailsView.title.text = owner.profile[@"name"];
    self.mainView.detailsView.subTitle.text = [activity summaryInfo];
    self.mainView.mainText.text = activity.summaryText;
    self.mainView.title.text = activity.title;
    
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
}

- (int)cellHeight:(NSString *)text
{
    NSString *previewText = text;
    if ([text length] > 250)
     previewText = [text substringToIndex:250];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text
                                                                 attributes:[NSDictionary dictionaryWithObject:self.mainView.mainText.font forKey:NSFontAttributeName]];
    
    CGFloat fontSize = self.mainView.mainText.font.pointSize;
    
    CGFloat offset = CELL_BORDER_SIZE + CELL_PADDING;
    CGRect screenRect = CGRectInset([[UIScreen mainScreen] bounds], offset, offset);
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                       context:nil];
    
    float height = rect.size.height < fontSize ? fontSize : rect.size.height;
    
    //@"V:|-16-[detailsView]-18-[_title(titleHeight)]-6-[mainText]-[_continueLabel]-(>=16)-|"
    return  CELL_PADDING +
            STANDARD_PADDING +
            52 + // self.detailsView.frame.size.height +
            18 +
            18 + // title height
            6 +
            height + // self.mainText.frame.size.height +
            6 +
            14 + // continue height
            STANDARD_PADDING +
            CELL_BORDER_SIZE + CELL_PADDING;
}

@end
