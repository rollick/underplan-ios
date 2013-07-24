//
//  ActivityViewController.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityViewController.h"

@interface ActivityViewController ()

@property (strong, nonatomic) NSMutableDictionary *owner;

- (void)setActivityDetails;

@end

@implementation ActivityViewController

- (void)setActivity:(id)newActivity
{
    if (_activity != newActivity) {
        _activity = newActivity;
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

- (void)configureMeteor
{
    NSArray *params = @[_activity[@"_id"]];
    [_meteor addSubscription:@"activityShow" parameters:params];
}

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
	// Do any additional setup after loading the view.
    
    [self setActivityDetails];
}

- (void)setActivityDetails
{
    _activityText.text = _activity[@"text"];
    
    if([_activity[@"title"] isKindOfClass:[NSString class]])
    {
        _activityTitle.text = _activity[@"title"];
    }
    else
    {
        _activityTitle.text = @"Testing";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Activities";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"removed"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveUpdate:(NSNotification *)notification
{
    [self setActivityDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end