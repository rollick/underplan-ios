//
//  UnderplanTableViewCell.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTableViewCell.h"
#import "UnderplanViewConstants.h"

#import "UIColor+Underplan.h"

#import "User.h"
#import "Activity.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self.containerView)
        return self;
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.containerView = [[UIView alloc] init];
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:self.containerView];
    [self.contentView bringSubviewToFront:self.containerView];
//    self.contentView.layer.backgroundColor = [UIColor orangeColor].CGColor;

    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.underLineView = [[UIView alloc] init];
    self.underLineView.backgroundColor = [UIColor underplanPrimaryColor];
    [self.underLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
//    self.containerView.layer.backgroundColor = [UIColor redColor].CGColor;
    
    [self.containerView addSubview:self.underLineView];

    [self.layer setCornerRadius:2.0f];
    [self.layer setMasksToBounds:YES];
//    self.layer.backgroundColor = [UIColor blueColor].CGColor;

    NSDictionary *viewsDictionary = @{@"containerView": self.containerView,
                                      @"border": self.underLineView};
    
    NSDictionary *metrics = @{@"padding": @CELL_PADDING,
                              @"borderSize": @CELL_BORDER_SIZE,
                              @"standardPadding": @STANDARD_PADDING};
    
    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[containerView]-(0)-[border(borderSize)]-(standardPadding@500)-|"
                                             options:0
                                             metrics:metrics
                                               views:viewsDictionary]];

    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[containerView]-(padding)-|"
                                             options:NSLayoutFormatAlignAllTop
                                             metrics:metrics
                                               views:viewsDictionary]];

    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[border]-0-|"
                                             options:NSLayoutFormatAlignAllTop
                                             metrics:metrics
                                               views:viewsDictionary]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)loadActivity:(Activity *)activity
{
    
}

- (void)loadActivityImage:(Activity *)activity
{

}

- (int)cellHeight:(NSString *)text
{
    // Subclass and override
    return 10;
}

@end
