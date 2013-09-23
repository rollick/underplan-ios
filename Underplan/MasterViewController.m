//
//  MasterViewController.m
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "MasterViewController.h"
#import "GroupViewController.h"
#import "WebViewController.h"

#import "UIViewController+UnderplanApiNotifications.h"
#import "UIViewController+ShowHideBars.h"
#import "UIViewController+BarColor.h"

#import "UnderplanAppDelegate.h"
#import "SharedApiClient.h"
#import "GroupItemViewCell.h"

#import "Group.h"

#import "UIColor+Underplan.h"

@interface MasterViewController ()

@property (assign, nonatomic) BOOL connectedToMeteor;
@property (strong, nonatomic) NSMutableArray *_groups;
@property (assign, nonatomic) UnderplanAppDelegate *appDelegate;

@end

@implementation MasterViewController {
    int tableOffset;
}

@synthesize tableView, addGroupView, exploreLabel;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Underplan";
    
    [self hideBars];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView registerClass:[GroupItemViewCell class] forCellReuseIdentifier:@"Group"];
    [self.tableView setContentInset:UIEdgeInsetsMake(tableOffset, 0, 0, 0)];
//    [self.tableView setBounces:NO];
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    self.connectionStatusText.text = @"Connected to Underplan!";
    self.connectedToMeteor = YES;

    if ([[notification name] isEqualToString:@"added"]) {
        self._groups = [SharedApiClient getClient].collections[@"groups"];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init];
    NSString *bgName;
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight > 480)
    {
        bgName = @"bg_iphone5.png";
    }
    else
    {
        bgName = @"bg_iphone4.png";
    }

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:bgName]];
    
    UIBarButtonItem *reconnectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reconnectSocket)];
    self.navigationItem.rightBarButtonItem = reconnectButton;
    
    [self setupTableView];
    [self setupGroupView];
}

- (void)setupTableView
{
    tableOffset = 130;
    
    // Table View
    self.tableView = [[UITableView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Add product name
    NSNumber *labelHeight = @50;
    NSNumber *labelPositionY = @50;
    self.productLabel = [[UILabel alloc] init];
    self.productLabel.text = @"underplan";
    self.productLabel.textAlignment = NSTextAlignmentCenter;
    self.productLabel.textColor = [UIColor underplanPrimaryDarkColor];
    self.productLabel.font = [UIFont fontWithName:@"LilyScriptOne-Regular" size:[labelHeight integerValue]];
    self.productLabel.backgroundColor = [UIColor clearColor];
    [self.productLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.view addSubview:self.productLabel];
    
    NSString *format = @"H:|-(>=0)-[productName]-(>=0)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:@{@"productName": self.productLabel}]];
    
    format = @"V:|-(lblPositionY)-[productName(lblHeight)]-(>=0)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"lblHeight": labelHeight,
                                                                                @"lblPositionY": labelPositionY}
                                                                        views:@{@"productName": self.productLabel}]];
    
    // Center the button horizontally with the parent view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.productLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (void)setupGroupView
{
    self.addGroupView = [[UIView alloc] init];
    
    NSNumber *btnWidth = @200;
    NSNumber *btnHeight = @50;
    NSNumber *btnPositionY = @250;
    
    self.addGroupView.backgroundColor = [UIColor underplanPrimaryColor];
    self.addGroupView.layer.borderColor = [UIColor underplanPrimaryDarkColor].CGColor;
    self.addGroupView.layer.borderWidth = 1;
    self.addGroupView.layer.masksToBounds = YES;
    self.addGroupView.layer.cornerRadius = [btnHeight floatValue] / 2;
    
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWebURL:)];
    [self.addGroupView addGestureRecognizer:tapGesture];
    [self.addGroupView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.addGroupView.alpha = 0.0f;
    [self.view addSubview:self.addGroupView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(addGroupView);
    
    NSString *format = @"H:|-(>=0)-[addGroupView(width)]-(>=0)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"width": btnWidth}
                                                                        views:viewsDictionary]];

    // Center the button horizontally with the parent view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addGroupView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    NSNumber *textHeight = @16;
    UILabel *btnLabel = [[UILabel alloc] init];
    btnLabel.text = @"Create your journey";
    btnLabel.textAlignment = NSTextAlignmentCenter;
    btnLabel.textColor = [UIColor whiteColor];
    btnLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:[textHeight integerValue]];
    btnLabel.backgroundColor = [UIColor clearColor];
    [btnLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.addGroupView addSubview:btnLabel];
    
    viewsDictionary = NSDictionaryOfVariableBindings(btnLabel);
    
    format = @"H:|-(0)-[btnLabel(width)]-(0)-|";
    [self.addGroupView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:@{@"width": btnWidth}
                                                                        views:viewsDictionary]];

    format = @"V:|-(>=0)-[btnLabel(height)]-(>=0)-|";
    [self.addGroupView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"height": textHeight}
                                                                        views:viewsDictionary]];
    
    [self.addGroupView addConstraint:[NSLayoutConstraint constraintWithItem:btnLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.addGroupView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    [self.addGroupView addConstraint:[NSLayoutConstraint constraintWithItem:btnLabel
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:[textHeight floatValue]]];
    
    // Explore Label
    exploreLabel = [[UILabel alloc] init];
    NSNumber *lblHeight = @16;
    exploreLabel.text = @"Or, Explore";
    exploreLabel.textColor = [UIColor whiteColor];
    exploreLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:[lblHeight integerValue]];
    exploreLabel.backgroundColor = [UIColor clearColor];
    [exploreLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.exploreLabel.alpha = 0.0f;
    [self.view addSubview:exploreLabel];
    
    viewsDictionary = NSDictionaryOfVariableBindings(addGroupView, exploreLabel);
    
    format = @"V:|-(btnPositionY)-[addGroupView(btnHeight)]-(20)-[exploreLabel(lblHeight)]-(>=0)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"lblHeight": lblHeight,
                                                                                @"btnHeight": btnHeight,
                                                                                @"btnPositionY": btnPositionY}
                                                                        views:viewsDictionary]];
    
    // Center the label horizontally with the parent view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addGroupView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
}

- (void)openWebURL:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://underplan.it/new"]];
    
//    WebViewController *webController = [[WebViewController alloc] initWithUrl:@"http://underplan.it/new"];
//    
//    [self.navigationController pushViewController:webController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reconnectSocket
{
    [[SharedApiClient getClient].ddp connectWebSocket];
    [[SharedApiClient getClient] resetCollections];

    self._groups = [SharedApiClient getClient].collections[@"groups"];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // return if views not initialised
    if (!scrollView || !self.exploreLabel)
        return;
    
    [self setFadeForGroupAddView:scrollView.contentOffset.y];
    [self setFadeForProductLabel:scrollView.contentOffset.y];
}

- (void)setFadeForProductLabel:(int)scrollViewYOffset
{
    // Fade in / out group button and labels
    int lblOffset = self.productLabel.frame.origin.y + self.productLabel.frame.size.height;
    int diff = scrollViewYOffset + lblOffset;
    int proximity = -15;
    
    // return if exploreLabel at 0 => layout not complete
    if (!lblOffset)
        return;
    
    if (diff > proximity)
    {
        if (self.productLabel.alpha == 1.0f)
            [self fadeOutLabel:self.productLabel];
    }
    else
    {
        if (self.productLabel.alpha == 0.0f)
            [self fadeInLabel:self.productLabel];
    }
}

- (void)setFadeForGroupAddView:(int)scrollViewYOffset
{
    // Fade in / out group button and labels
//    int yOffset = scrollView.contentOffset.y;
    int lblOffset = self.exploreLabel.frame.origin.y + self.exploreLabel.frame.size.height;
    int diff = scrollViewYOffset + lblOffset;
    int proximity = -15;
    
    // return if exploreLabel at 0 => layout not complete
    if (!lblOffset)
        return;
    
    if (diff > proximity)
    {
        if (diff < 0)
        {
            float a = diff/(float)proximity;
            self.addGroupView.alpha = a;
            self.exploreLabel.alpha = a;
        }
        else
        {
            self.addGroupView.alpha = 0.0f;
            self.exploreLabel.alpha = 0.0f;
        }
    }
    else
    {
        self.addGroupView.alpha = 1.0f;
        self.exploreLabel.alpha = 1.0f;
    }
}

- (void)fadeOutLabel:(UILabel *)label
{
    // Fade out the label right away
    [UIView animateWithDuration:0.15
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         label.alpha = 0.0;
                     }
                     completion:nil];
}

- (void)fadeInLabel:(UILabel *)label
{
    // Fade out the label right away
    [UIView animateWithDuration:0.15
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         label.alpha = 1.0;
                     }
                     completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self._groups.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: calculate this based on cell content...
    GroupItemViewCell *item = [[GroupItemViewCell alloc] init];
    
    return [item cellHeight:@""];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupItemViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Group" forIndexPath:indexPath];
    
    Group *group = [[Group alloc] initWithId:self._groups[indexPath.row][@"_id"]];
    
    cell.title.text = group.name;
    cell.description.text = group.details;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self._groups removeObjectAtIndex:indexPath.row];
        [aTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showGroup" sender:self.tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showGroup"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *data = self._groups[indexPath.row];
        Group *group = [[Group alloc] initWithId:data[@"_id"]];
        [[segue destinationViewController] setGroup:group];
    }
}

@end
