//
//  UnderplanShortItemCell.m
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanShortItemCell.h"
#import "UnderplanActivityView.h"
#import "UnderplanViewConstants.h"

#import "UIColor+Underplan.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanShortItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if ([reuseIdentifier isEqualToString:@"ShortWithImage"])
    {
        _style = ShortStyleWithImage;
    }
    else if ([reuseIdentifier isEqualToString:@"Short"])
    {
        _style = ShortStyle;
    }
    
    self.mainView = [[UnderplanActivityView alloc] initWithStyle:_style];
    self.mainView.backgroundColor = [UIColor underplanCellBgColor];
    [self.mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.containerView addSubview:self.mainView];
    
    NSDictionary *viewsDictionary = @{@"mainView": self.mainView};
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllLeft
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainView]|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    
    return self;
}

- (void)initView
{
    [super initView];

    self.containerView.layer.backgroundColor = [UIColor brownColor].CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)loadActivity:(Activity *)activity
{
    [super loadActivity:activity];

    // Fetch owner and id for cell
    self.itemId = activity.remoteId;
    User *owner = [[User alloc] initWithId:activity.ownerId];
    
    if (activity.tags && [activity.tags length] > 0)
        _style = ShortStyleWithImage;
    else
        _style = ShortStyle;
    
    // Set the owners name as the title
    self.mainView.detailsView.title.text = owner.profile[@"name"];
    self.mainView.detailsView.subTitle.text = [activity summaryInfo];
    self.mainView.mainText.text = activity.summaryText;

    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [self.mainView.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                                 options:SDWebImageRefreshCached];
    }
    
    self.loaded = YES;
}

- (void)loadActivityImage:(UIImage *)image
{
//    if (!self.mainView.contentImage)
//        self.mainView.contentImage = [[UIImageView alloc] init];
//    
    [self.mainView.contentImage setImage:image];
}

- (void)clearActivityImage
{
    self.mainView.contentImage = nil;
}

- (int)cellHeight:(NSString *)text
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text
                                                                 attributes:[NSDictionary dictionaryWithObject:self.mainView.mainText.font forKey:NSFontAttributeName]];
    
    CGFloat fontSize = self.mainView.mainText.font.pointSize;
    
    CGFloat offset = STANDARD_PADDING + CELL_PADDING;
    CGRect screenRect = CGRectInset([[UIScreen mainScreen] bounds], offset, offset);
    CGFloat screenWidth = screenRect.size.width;
    float height;
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(screenWidth, 2000)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                       context:nil];
    
    height = rect.size.height < fontSize+10 ? fontSize+10 : rect.size.height;
    
    int cellHeight = CELL_PADDING +
                    STANDARD_PADDING +
                    52 + // self.detailsView.frame.size.height +
                    STANDARD_PADDING +
                    height + // self.mainText.frame.size.height +
                    STANDARD_PADDING;
    
    if (_style == ShortStyleWithImage)
        cellHeight += 150;
    
    return cellHeight + CELL_BORDER_SIZE + CELL_PADDING;
}

@end
