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
    self.lowerLine = [[UIView alloc] init];
    self.lowerLine.backgroundColor = [UIColor underplanBgColor];
    [self.contentView addSubview:self.lowerLine];
    
    self.upperLine = [[UIView alloc] init];
    self.upperLine.backgroundColor = [UIColor underplanPrimaryColor];
    [self.contentView addSubview:self.upperLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int paddingHeight = 10;
    int paddingPosition = self.frame.size.height - paddingHeight;
    if (CELL_BORDER_SIZE) {
        paddingPosition = paddingPosition - CELL_BORDER_SIZE;
    }
    
    int borderHeight = 2;
    int borderPosition = self.frame.size.height - borderHeight - paddingHeight;
    if (CELL_BORDER_SIZE) {
        borderPosition = borderPosition - CELL_BORDER_SIZE;
    }
    
    [self.upperLine setFrame:CGRectMake(0, borderPosition, self.frame.size.width, borderHeight)];
    [self.lowerLine setFrame:CGRectMake(0, paddingPosition, self.frame.size.width, paddingHeight)];
}

- (int)cellHeight:(NSString *)text
{
    // Subclass and override
    return 10;
}

@end
