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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        for (id controller in [self viewControllers]) {
            if ([controller respondsToSelector:@selector(delegate)]) {
                [controller setValue:self forKey:@"delegate"];
            } else {
                [self addObserver:controller
                       forKeyPath:@"group"
                          options:(NSKeyValueObservingOptionNew |
                                   NSKeyValueObservingOptionOld)
                          context:NULL];
            }
        }
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
