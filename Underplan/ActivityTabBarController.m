//
//  ActivityTabBarController.m
//  Underplan
//
//  Created by Mark Gallop on 31/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "ActivityTabBarController.h"

@interface ActivityTabBarController ()

@end

@implementation ActivityTabBarController

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
    
    for (id controller in [self viewControllers]) {
        if ([controller respondsToSelector:@selector(group)]) {
            [controller setValue:_group forKey:@"group"];
        }

        if ([controller respondsToSelector:@selector(activity)]) {
            [controller setValue:_activity forKey:@"activity"];
        }

        if ([controller respondsToSelector:@selector(searchTags)]) {
            NSString *tags = _activity[@"picasaTags"];
            // If the tags field is nil then set to a blank string as no images
            // will be returned with a blank query string
            if (_activity[@"picasaTags"] == nil) {
                tags = @"";
            }
            [controller setValue:tags forKey:@"searchTags"];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setActivity:(id)newActivity
{
    if (_activity != newActivity) {
        _activity = newActivity;
    }
}

- (void)setGroup:(id)newGroup
{
    if (_group != newGroup) {
        _group = newGroup;
    }
}

@end
