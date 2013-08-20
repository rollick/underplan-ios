//
//  UserItemView.h
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserItemView : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *subTitle;
@property (nonatomic, retain) IBOutlet UILabel *mainText;
@property (nonatomic, retain) IBOutlet UIImageView *contentImage;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *marginTop;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *marginBottom;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *imageTextPadding;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *photoContentPadding;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *photoHeight;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *contentMarginBottom;

- (CGFloat)cellHeight:(NSString *)text;

@end
