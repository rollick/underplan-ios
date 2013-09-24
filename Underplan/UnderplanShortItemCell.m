//
//  UnderplanShortItemCell.m
//  Underplan
//
//  Created by Mark Gallop on 1/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanShortItemCell.h"
#import "UnderplanShortView.h"

#import "UIColor+Underplan.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanShortItemCell

- (id)initWithStyle:(ShortStyle)aStyle
{
    _style = aStyle;
    
    self.mainView = [[UnderplanShortView alloc] initWithStyle:_style];
    self.mainView.backgroundColor = [UIColor underplanCellBgColor];
    [self.containerView addSubview:self.mainView];
    
    self = [super init];
    
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

    [self.mainView setFrame:CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height)];
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
        _style = ShortStyleDefault;

    if (!self.mainView)
    {
        self.mainView = [[UnderplanShortView alloc] initWithStyle:_style];
        self.mainView.backgroundColor = [UIColor underplanCellBgColor];
        [self.containerView addSubview:self.mainView];
    }
    
    // Set the owners name as the title
    self.mainView.detailsView.title.text = owner.profile[@"name"];
    self.mainView.detailsView.subTitle.text = [activity summaryInfo];
    self.mainView.mainText.text = activity.summaryText;

    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [self.mainView.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                               placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
//    self.mainView.mainText.layer.borderWidth = 1.0;
//    self.mainView.mainText.layer.borderColor = [UIColor orangeColor].CGColor;
    
    self.loaded = YES;
}

- (void)loadActivityImage:(Activity *)activity
{
    NSString *photoUrl = [activity photoUrl];
    if (photoUrl && ![photoUrl isEqual:@""])
    {
        [self.mainView.contentImage setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
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
    
    CGRect screenRect = CGRectInset([[UIScreen mainScreen] bounds], 32, 32);
    CGFloat screenWidth = screenRect.size.width;
    float height;
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(200, 2000)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                       context:nil];
    
    height = rect.size.height < fontSize+10 ? fontSize+10 : rect.size.height;
    
    int cellHeight = BOTTOM_BORDER_SIZE*2 + CELL_BORDER_SIZE*2 +
            16 +
            52 + // self.detailsView.frame.size.height +
            16 +
            height; // self.mainText.frame.size.height +
    
    if (_style == ShortStyleWithImage)
        cellHeight += 150;
    
    return cellHeight;
}

@end
