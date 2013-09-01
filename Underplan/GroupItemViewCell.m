//
//  GroupItemViewCell.m
//  Underplan
//
//  Created by Mark Gallop on 29/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "GroupItemViewCell.h"

#import <UIColor+HexString.h>

@implementation GroupItemViewCell

@synthesize title, description;

- (void)initView
{
    [super initView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.masksToBounds = YES;
//    self.layer.borderColor = [UIColor colorWithHexString:@"#E0E0E0"].CGColor;
//    self.layer.borderWidth = 8.0;
    
    self.title = [[UILabel alloc] init];
    self.title.text = @"A Test Title";
    
    [self.title setFont:[UIFont fontWithName:@"Helvetica-Light" size:18]];
    [self.title setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:self.title];
    
    self.description = [[UILabel alloc] init];
    [self.description setFont:[UIFont fontWithName:@"Helvetica-Light" size:14]];
    self.description.text = @"A Test Description";
    [self.description setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:self.description];
    
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, description);
    
    NSString *format = @"V:|-16-[title]-(0)-[description]-(>=16)-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.contentView addConstraints:constraintsArray];
    
    format = @"|-16-[title]-16-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.contentView addConstraints:constraintsArray];
    
    format = @"|-16-[description]-16-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.contentView addConstraints:constraintsArray];
}

- (int)cellHeight
{
    return 120;
}

@end
