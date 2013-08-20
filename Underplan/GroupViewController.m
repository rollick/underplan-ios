//
//  GroupViewController.m
//  Underplan
//
//  Created by Mark Gallop on 9/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "GroupViewController.h"
#import "ActivityListViewController.h"

#import "UIColor+FlatUI.h"

@interface GroupViewController ()

@property (strong, nonatomic) NSMutableArray *_activities;

- (void)configureMeteor;

@end

@implementation GroupViewController

- (void)configureMeteor
{
    NSArray *params = @[@{@"groupId":_group[@"_id"], @"limit":@10}];
    [_meteor addSubscriptionWithParameters:@"feedActivities" paramaters:params];
    
    // Update the user interface for the group.
    self._activities = self.meteor.collections[@"activities"];
}

- (void)setGroup:(id)newGroup
{
    if (_group != newGroup) {
        _group = newGroup;
    }
}

- (void)setMeteor:(id)newMeteor
{
    if (_meteor != newMeteor) {
        _meteor = newMeteor;
        
        // Update the view.
        [self configureMeteor];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"removed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"ready"
                                               object:nil];
}


- (void)didReceiveUpdate:(NSNotification *)notification
{
    // Reload list
    // FIXME: need to check which tab is visible and reload that one here
    //        ... possibly need to set a flag on the hidden tab to tell it
    //        to reload when it becomes visible.
    [[[self viewControllers] objectAtIndex:0] reloadData];
    [[[self viewControllers] objectAtIndex:1] reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // First should be the map
    [[[self viewControllers] objectAtIndex:0] setMeteor:self.meteor];
    [[[self viewControllers] objectAtIndex:0] setGroup:self.group];

    // Second should be the list
    [[[self viewControllers] objectAtIndex:1] setMeteor:self.meteor];
    [[[self viewControllers] objectAtIndex:1] setGroup:self.group];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
