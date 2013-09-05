//
//  ItemDetailsView.h
//  Underplan
//
//  Created by Mark Gallop on 28/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderplanItemDetailsView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;

@end
