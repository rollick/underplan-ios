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
    tabBarImageNames = @[@{@"selected": @"calendar_full.png",
                           @"unselected": @"calendar.png"},
                         @{@"selected": @"pin_full.png",
                           @"unselected": @"pin.png"},
                         @{@"selected": @"photos_full.png",
                           @"unselected": @"photos.png"}];
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}

@end
