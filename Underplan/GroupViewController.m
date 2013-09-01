//
//  GroupViewController.m
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "GroupViewController.h"
#import "ActivityListViewController.h"
#import "ActivityMapViewController.h"

@interface GroupViewController ()

@property (strong, nonatomic) NSMutableArray *_activities;

@end

@implementation GroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    for (id controller in [self viewControllers]) {
        if ([controller respondsToSelector:@selector(group)]) {
            [controller setValue:self.group forKey:@"group"];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
