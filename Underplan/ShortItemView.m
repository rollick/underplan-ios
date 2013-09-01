//
//  ShortItemView.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ShortItemView.h"

@implementation ShortItemView

@synthesize contentImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initView
{
    [super initView];
    
    self.contentImage = [[UIImageView alloc] init];
    self.contentImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImage.clipsToBounds = YES;
    [self.contentView addSubview:self.contentImage];
    
    UITextView *mainText = self.mainText;
    ItemDetailsView *detailsView = self.detailsView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView, contentImage);
    
    NSString *format = @"V:|-16-[detailsView]-16-[mainText]-(>=0)-[contentImage]-(12)-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];

    [self.contentView addConstraints:constraintsArray];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.contentImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:150];
    
    [self.contentView addConstraint:constraint];
    
    format = @"|-0-[contentImage]-0-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.contentView addConstraints:constraintsArray];
}

- (int)cellHeight:(NSString *)text
{
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:self.mainText.font forKey: NSFontAttributeName];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil];
    
    return  16 +
            52 + // self.detailsView.frame.size.height +
            16 +
            rect.size.height + // self.mainText.frame.size.height +
            20 +
            16 +
            150 + // self.contentImage.frame.size.height +
            12;
    
}

@end
