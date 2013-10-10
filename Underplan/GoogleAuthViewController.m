//
//  GoogleAuthViewController.m
//  Underplan
//
//  Created by Mark Gallop on 5/10/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "GoogleAuthViewController.h"

#import "UIViewController+BarColor.h"
#import "UIViewController+ShowHideBars.h"

@interface GoogleAuthViewController ()

@end

@implementation GoogleAuthViewController

+ (NSString *)authNibName {
    // subclasses may override this to specify a custom nib name
    return @"GoogleAuthView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(bool)isNavigationBarTranslucent
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.backButton.layer setShadowColor:[UIColor clearColor].CGColor];
    [self.backButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.backButton.layer setShadowOffset:CGSizeMake(0, 0)];
    
    [self setDefaultBarColor];
    
    if (self.navigationController.navigationBar.hidden)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
