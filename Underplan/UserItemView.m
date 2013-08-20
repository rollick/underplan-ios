//
//  UserItemView.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UserItemView.h"

@implementation UserItemView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // init code here...
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)cellHeight:(NSString *)text
{
    if ([text length] > 250)
    {
        self.mainText.text = [text substringToIndex:250];
    } else {
        self.mainText.text = text;
    }
    
    CGSize textSize = [self.mainText.text sizeWithFont:self.mainText.font constrainedToSize:CGSizeMake(self.mainText.frame.size.width, MAXFLOAT) lineBreakMode:self.mainText.lineBreakMode];
    
    return  textSize.height +
            self.marginTop.constant +
            self.image.frame.size.height +
            self.photoContentPadding.constant +
            self.contentImage.frame.size.height +
            self.marginBottom.constant + 30; // random 30 added... missing something :-(
}

- (CGFloat)textHeight:(NSString *)text
{
    if ([text length] > 250)
    {
        self.mainText.text = [text substringToIndex:250];
    } else {
        self.mainText.text = text;
    }
    
    CGSize textSize = [self.mainText.text sizeWithFont:self.mainText.font constrainedToSize:CGSizeMake(self.mainText.frame.size.width, MAXFLOAT) lineBreakMode:self.mainText.lineBreakMode];
    
    return  textSize.height;
}

@end
