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

#define CELL_PADDING 8
#define TITLE_HEIGHT 18

@implementation GroupItemViewCell

static int descriptionHeight = 14;
static int descriptionWidth = 280;

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
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.containerView.backgroundColor = [UIColor underplanGroupCellColor];
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 3.0;
    self.containerView.layer.borderColor = [UIColor underplanDarkMenuColor].CGColor;
    self.containerView.layer.borderWidth = 1.0;
    
    [self.contentView addSubview:self.containerView];
    [self.contentView bringSubviewToFront:self.containerView];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    NSNumber *titleHeight = [[NSNumber alloc] initWithInt:TITLE_HEIGHT];
    self.title = [[UILabel alloc] init];
    [self.title setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.title.text = @"A Test Title";
    self.title.textColor = [UIColor underplanGroupCellTitleColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.font = [UIFont fontWithName:@"Roboto-Medium" size:[titleHeight integerValue]];
    self.title.backgroundColor = [UIColor clearColor];
    
    [self.containerView addSubview:self.title];
    
    self.description = [[UILabel alloc] init];
    [self.description setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.description.font = [UIFont fontWithName:@"Roboto-Light" size:descriptionHeight];
    self.description.text = @"A Test Description";
    self.description.textColor = [UIColor underplanGroupCellTextColor];
    self.description.backgroundColor = [UIColor clearColor];
    self.description.numberOfLines = 0;
    self.description.lineBreakMode = NSLineBreakByWordWrapping;
    self.description.textAlignment = NSTextAlignmentCenter;
        
    [self.containerView addSubview:self.description];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = @{@"title": self.title, @"description": self.description};

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(16)-[title]-(16)-[description]-(16@250)-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[title]-(padding)-|"
                                                                   options:NSLayoutFormatAlignAllTop
                                                                   metrics:@{@"padding" : @16}
                                                                     views:viewsDictionary]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[description]-(padding)-|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:@{@"padding" : @16}
                                                                                 views:viewsDictionary]];
    
    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[container]-(padding)-|"
                                             options:NSLayoutFormatAlignAllTop
                                             metrics:@{@"padding": [[NSNumber alloc] initWithInt:CELL_PADDING]}
                                               views:@{@"container": self.containerView}]];

    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[container]-(padding)-|"
                                             options:NSLayoutFormatAlignAllLeft
                                             metrics:@{@"padding": [[NSNumber alloc] initWithInt:CELL_PADDING]}
                                               views:@{@"container": self.containerView}]];
    
//    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.title
//                                                                   attribute:NSLayoutAttributeTop
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self.containerView
//                                                                   attribute:NSLayoutAttributeLeading
//                                                                  multiplier:1.0 constant:16.0]];
//
//    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.title
//                                                                   attribute:NSLayoutAttributeCenterX
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self.containerView
//                                                                   attribute:NSLayoutAttributeCenterX
//                                                                  multiplier:1.0 constant:0.0]];
//    
//    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.description
//                                                                   attribute:NSLayoutAttributeWidth
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:nil
//                                                                   attribute:0
//                                                                  multiplier:1.0 constant:descriptionWidth]];
//    
//    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.description
//                                                                   attribute:NSLayoutAttributeCenterX
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self.containerView
//                                                                   attribute:NSLayoutAttributeCenterX
//                                                                  multiplier:1.0 constant:0.0]];
    
//    NSString *
//    format = @"|-16-[title]-16-|";
//    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
//                                                                               options:NSLayoutFormatAlignAllLeft
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];
//    
//    format = @"|-16-[description]-16-|";
//    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=16)-[description]-(>=16)-|"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];
//
//    format = @"V:|-16-[title]-(8)-[description]-(>=0)-|";
//    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
//                                                                        options:NSLayoutFormatAlignAllCenterX
//                                                                               metrics:@{@"titleHeight": @20}
//                                                                          views:viewsDictionary]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    
//    CGRect frame = self.contentView.frame;
//    self.containerView.frame = CGRectInset(frame, CELL_PADDING, CELL_PADDING);
}

- (int)cellHeight:(NSString *)description withTitle:(NSString *)title
{
    CGFloat offset = CELL_PADDING + 16;
    CGRect screenRect = CGRectInset([[UIScreen mainScreen] bounds], offset, offset);
    CGFloat screenWidth = screenRect.size.width;

    // Calculate description height
    NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:title
                                                                      attributes:[NSDictionary dictionaryWithObject:self.title.font forKey:NSFontAttributeName]];
    
    CGRect titleRect = [titleString boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];
    
    // Calculate description height
    NSAttributedString *descriptionString = [[NSAttributedString alloc] initWithString:description
                                                                            attributes:[NSDictionary dictionaryWithObject:self.description.font forKey:NSFontAttributeName]];
    
    CGRect descriptionRect = [descriptionString boundingRectWithSize:CGSizeMake(descriptionWidth, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil];
    
    return  16 +
            titleRect.size.height +
            15 +
            descriptionRect.size.height +
            16 +
            CELL_PADDING*2;
}

@end
