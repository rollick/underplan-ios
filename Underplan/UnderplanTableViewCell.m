//
//  UnderplanTableViewCell.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanTableViewCell.h"

#import "UIColor+Underplan.h"

@implementation UnderplanTableViewCell

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
    
//    self.containerView.backgroundColor = [UIColor underplanGroupCellColor];
//    self.containerView.layer.masksToBounds = YES;
//    self.containerView.layer.cornerRadius = 3.0;
//    self.containerView.layer.borderColor = [UIColor underplanDarkMenuColor].CGColor;
//    self.containerView.layer.borderWidth = 1.0;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.underLineView = [[UIView alloc] init];
    self.underLineView.backgroundColor = [UIColor underplanPrimaryColor];
    [self.containerView addSubview:self.underLineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (CELL_BORDER_SIZE) {
        CGRect frame = self.contentView.frame;
        self.containerView.frame = CGRectInset(frame, CELL_BORDER_SIZE, CELL_BORDER_SIZE);
    }

    [self.underLineView setFrame:CGRectMake(0, self.containerView.bounds.size.height, self.containerView.bounds.size.width, BOTTOM_BORDER_SIZE)];
}

- (int)cellHeight:(NSString *)text
{
    // Subclass and override
    return 10;
}

@end
