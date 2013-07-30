//
//  UserItemView.h
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserItemView : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UILabel *mainText;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTextPadding;

- (CGFloat)cellHeight:(NSString *)text;

@end
