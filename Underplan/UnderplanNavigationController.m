//
//  UnderplanNavigationController.m
//  Underplan
//
//  Created by Mark Gallop on 20/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanNavigationController.h"

#import "UnderplanBarBackgroundView.h"

#import "UIColor+Underplan.h"

@interface UnderplanNavigationController ()

@end

@implementation UnderplanNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setup navbar with subview for nicer translucency
    [self setBarBackgroundTint:[UIColor underplanDarkMenuColor]];
}

- (void)setBarBackgroundTint:(UIColor *)color
{
    [self setBarBackgroundTint:color withFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
}

- (void)setBarBackgroundTint:(UIColor *)color withFrame:(CGRect)frame
{
    UnderplanBarBackgroundView *colourView = [[UnderplanBarBackgroundView alloc] initWithFrame:frame];
    
    colourView.opaque = NO;
    colourView.alpha = .7f;
    UIColor *barColour = color;
    colourView.backgroundColor = color;
    self.navigationBar.barTintColor = barColour;
    
    [self.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
