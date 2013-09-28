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

static void * const ActivityViewKVOContext = (void*)&ActivityViewKVOContext;

@synthesize mainView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self initView];
        
        [self addObserver:self
               forKeyPath:@"activity"
                  options:(NSKeyValueObservingOptionNew |
                           NSKeyValueObservingOptionOld)
                  context:ActivityViewKVOContext];
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
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_delegate)
    {
        // TODO: this should be a pointer to a property on the delegate
        //       rather than a method returning a value - with current
        //       implementation we can't observe changes.
        _activity = [_delegate currentActivity];
    }
    
    CGRect frame = self.view.frame;
    self.mainView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.view.contentSize = CGSizeMake(self.mainView.bounds.size.width, self.mainView.bounds.size.height);
    
    [self reloadData];
}

- (void)initView
{
    self.view = [[UIScrollView alloc] init];
    //    self.view.scrollEnabled = YES;
    self.view.showsVerticalScrollIndicator = NO;
    self.view.showsHorizontalScrollIndicator = NO;
    self.view.bouncesZoom = YES;
    self.view.decelerationRate = UIScrollViewDecelerationRateFast;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.delegate = self;
    self.view.backgroundColor = [UIColor underplanBgColor];
    
    self.mainView = [[UnderplanUserItemView alloc] init];
    
    [self.view addSubview:self.mainView];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = YES;
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
    UILabel *mainText = self.mainView.mainText;
    UnderplanItemDetailsView *detailsView = self.mainView.detailsView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(mainText, detailsView);
    
    NSString *format = @"V:|-(16)-[detailsView]-16-[mainText]-(>=16)-|";
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary];
    
    [self.mainView addConstraints:constraintsArray];
    
    if ([_activity.type isEqual:@"story"]) {
        self.navigationItem.title = _activity.title;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    if ([keyPath isEqual:@"activity"] && _activity)
    {
        [self reloadData];
    }
}

-(void)dealloc
{
    // FIXME: temp fis for ios7 issue when view is scrolling and user navigates away
    self.view.delegate = nil;
    
    self.delegate = nil;
    [self removeObserver:self forKeyPath:@"activity"];
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
