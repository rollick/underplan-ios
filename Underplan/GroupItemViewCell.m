//
//  GroupItemViewCell.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "GroupItemViewCell.h"

#import "UIColor+Underplan.h"
#import <UIColor+HexString.h>

@implementation GroupItemViewCell

@synthesize title, description;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

- (void)initView
{    
    self.containerView = [[UIView alloc] init];
    [self.contentView addSubview:self.containerView];
    [self.contentView bringSubviewToFront:self.containerView];
    self.containerView.backgroundColor = [UIColor underplanGroupCellColor];
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 3.0;
    
    self.containerView.layer.borderColor = [UIColor underplanDarkMenuColor].CGColor;
    self.containerView.layer.borderWidth = 1.0;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.title = [[UILabel alloc] init];
    self.title.text = @"A Test Title";
    self.title.textColor = [UIColor underplanGroupCellTitleColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    
    NSNumber *titleHeight = @18;
    self.title.font = [UIFont fontWithName:@"Roboto-Medium" size:[titleHeight integerValue]];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.backgroundColor = [UIColor clearColor];
    
    [self.containerView addSubview:self.title];
    
    self.description = [[UILabel alloc] init];
    NSNumber *descriptionHeight = @14;
    self.description.font = [UIFont fontWithName:@"Roboto-Light" size:[descriptionHeight integerValue]];
    self.description.text = @"A Test Description";
    self.description.textColor = [UIColor underplanGroupCellTextColor];
    self.description.backgroundColor = [UIColor clearColor];
    self.description.numberOfLines = 2;
    self.description.lineBreakMode = NSLineBreakByWordWrapping;
    self.description.textAlignment = NSTextAlignmentCenter;

    self.description.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:self.description];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, description);
    
    NSString *format = @"V:|-16-[title(titleHeight)]-(5)-[description]-(>=0)-|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                        options:NSLayoutFormatAlignAllLeft
                                                                               metrics:@{@"titleHeight": titleHeight}
                                                                          views:viewsDictionary]];
    
    format = @"|-16-[title]-16-|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                               options:NSLayoutFormatAlignAllLeft
                                                               metrics:nil
                                                                 views:viewsDictionary]];
    
    format = @"|-16-[description]-16-|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                               options:NSLayoutFormatAlignAllLeft
                                                               metrics:nil
                                                                 views:viewsDictionary]];

    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.description
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:50]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.title
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:18]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    self.containerView.frame = CGRectInset(frame, 8.0, 8.0);
}

- (int)cellHeight:(NSString *)text
{
    return 120 + BOTTOM_BORDER_SIZE;
}

@end
