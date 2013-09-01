//
//  UserItemView.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>

#import "UserItemView.h"
#import "ItemDetailsView.h"

#import "UIColor+Underplan.h"

@implementation UserItemView {
    int cellBorderSize;
}

@synthesize detailsView, mainText, contentImage;

- (void)initView
{
    [super initView];
    
    self.backgroundColor = [UIColor clearColor];

    self.contentView.backgroundColor = [UIColor whiteColor];
    if (CELL_BORDER_SIZE) {
        self.contentView.layer.borderColor = [UIColor underplanBgColor].CGColor;
        self.contentView.layer.borderWidth = CELL_BORDER_SIZE;
    }
    
    self.detailsView = [[ItemDetailsView alloc] init];
    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:detailsView];
    
    self.mainText = [[UITextView alloc] init];
    self.mainText.userInteractionEnabled = NO;
    self.mainText.scrollEnabled = NO;
    self.mainText.contentMode = UIViewContentModeTop;
    self.mainText.contentInset = UIEdgeInsetsMake(-8,-4,-4,-4);

    [self.mainText setFont:[UIFont fontWithName:@"Helvetica-Light" size:14]];
    [self.mainText setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:mainText];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    NSString *format = @"|-16-[mainText]-16-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];

    [self.contentView addConstraints:constraintsArray];

    format = @"|-16-[detailsView]-16-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.contentView addConstraints:constraintsArray];
}

- (CGFloat)textHeight:(NSString *)text
{
    if ([text length] > 250)
    {
        self.mainText.text = [text substringToIndex:250];
    } else {
        self.mainText.text = text;
    }
    
    CGSize textSize = [self.mainText.text sizeWithFont:self.mainText.font constrainedToSize:CGSizeMake(self.mainText.frame.size.width, MAXFLOAT)];
    
    return textSize.height;
}

- (int)cellHeight:(NSString *)text
{
    return 250;
}

- (int)cellHeight
{
    return 250;
}

@end
