//
//  ActivityViewController.m
//  Underplan
//
//  Created by Mark Gallop on 24/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActivityViewController.h"
#import "CommentsViewController.h"
#import "UnderplanUserItemView.h"

#import "User.h"
#import "Activity.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Underplan.h"

@interface ActivityViewController ()

@property (assign, nonatomic) Activity *activity;
@property (strong, nonatomic) NSMutableDictionary *owner;

- (void)reloadData;

@end

@implementation ActivityViewController

@synthesize mainView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {

    }
    return self;
}

- (id)initWithDelegate:(id)aDelegate
{
    if (self = [super init])
    {
        _delegate = aDelegate;
        _activity = [_delegate currentActivity];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_delegate)
        _activity = [_delegate currentActivity];
    
    [self initView];
    
    CGRect frame = self.view.frame;
    self.mainView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.view.contentSize = CGSizeMake(self.mainView.bounds.size.width, self.mainView.bounds.size.height);
}

- (void)initView
{
    self.view = [[UIScrollView alloc] init];
//    self.view.scrollEnabled = YES;
    self.view.showsVerticalScrollIndicator = NO;
    self.view.showsHorizontalScrollIndicator = NO;
    self.view.bouncesZoom = YES;
    self.view.decelerationRate = UIScrollViewDecelerationRateFast;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.view.delegate = self;
    self.view.backgroundColor = [UIColor underplanBgColor];
    [self.view.layer setBorderColor:[UIColor redColor].CGColor];
    self.view.layer.borderWidth = 1.0f;
    
    self.mainView = [[UnderplanUserItemView alloc] init];
    [self.mainView.layer setBorderColor:[UIColor blueColor].CGColor];
    self.mainView.layer.borderWidth = 1.0f;
    
    [self.view addSubview:self.mainView];
    
    if (self.tabBarController) {
        UIEdgeInsets inset = self.view.contentInset;
        inset.bottom = self.tabBarController.tabBar.frame.size.height;
        self.view.contentInset = inset;
    }
    
    [self reloadData];
}

- (void)reloadData
{
    // Set the profile image
    User *owner = _activity.owner;
        
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    if ([profileImageUrl length]) {
        [self.mainView.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    // Set the text fields
    self.mainView.detailsView.subTitle.text = _activity.summaryInfo;
    self.mainView.detailsView.title.text = owner.profile[@"name"];
    self.mainView.mainText.text = _activity.text;
    
    // Add some constraints
    UITextView *mainText = self.mainView.mainText;
    UnderplanItemDetailsView *detailsView = self.mainView.detailsView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    NSString *format = @"V:|-(16)-[detailsView]-16-[mainText]-(>=16)-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.mainView addConstraints:constraintsArray];
    
    if ([_activity.type isEqual:@"story"]) {
        self.navigationItem.title = _activity.title;
    }
}

-(void)dealloc
{
    // FIXME: temp fis for ios7 issue when view is scrolling and user navigates away
    self.view.delegate = nil;
    
    self.delegate = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"activity"]) {
        [self setActivity:[change objectForKey:NSKeyValueChangeNewKey]];
        if ([self.mainView isKindOfClass:[UnderplanUserItemView class]]) {
            [self reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showComments"]) {
        [[segue destinationViewController] setActivity:_activity];
    }
}

@end
