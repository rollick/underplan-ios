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
//    self.mainView.layer.backgroundColor = [UIColor greenColor].CGColor;

    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [self.mainView.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                                 options:SDWebImageRefreshCached];
    }
    
    self.loaded = YES;
}

- (int)cellHeight:(NSString *)text
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text
                                                                 attributes:[NSDictionary dictionaryWithObject:self.mainView.mainText.font forKey:NSFontAttributeName]];
    
    CGFloat fontSize = self.mainView.mainText.font.pointSize;
    
    CGFloat offset = STANDARD_PADDING + CELL_PADDING;
    CGRect screenRect = CGRectInset([[UIScreen mainScreen] bounds], offset, offset);
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(screenWidth, 2000)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                       context:nil];
    
    float height = rect.size.height < fontSize ? fontSize : rect.size.height;
    
    int cellHeight = CELL_PADDING +
                    STANDARD_PADDING +
                    52 + // self.detailsView.frame.size.height +
                    STANDARD_PADDING +
                    height + // self.mainText.frame.size.height +
                    STANDARD_PADDING;
    
    if (_style == ShortStyleWithImage)
        cellHeight += CONTENT_IMAGE_HEIGHT;
    
    return cellHeight + CELL_BORDER_SIZE + STANDARD_PADDING;
}

@end
