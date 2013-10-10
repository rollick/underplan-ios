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
#import "UnderplanAuthKeys.h"

#import "UIViewController+UnderplanApiNotifications.h"
#import "UIViewController+ShowHideBars.h"

#import "UnderplanAppDelegate.h"
#import "SharedApiClient.h"
#import "GroupItemViewCell.h"

#import "GoogleAuthViewController.h"

#import "Group.h"

#import "UIColor+Underplan.h"
#import <BSONIdGenerator.h>
#import <MBProgressHUD.h>

static NSInteger const tablePositionY = 245;

static NSInteger const productNameHeight = 50;
static NSInteger const productNamePositionY = 45;

static NSInteger const btnWidth = 200;
static NSInteger const btnHeight = 50;
static NSInteger const btnPositionY = 135;
static NSInteger const btnTextHeight = 16;

static NSInteger const exploreLblHeight = 16;

static NSString *const kKeychainItemName = @"External Auth: Google+";

@interface MasterViewController ()

@property (assign, nonatomic) BOOL connectedToMeteor;
@property (strong, nonatomic) NSMutableArray *_groups;
@property (assign, nonatomic) UnderplanAppDelegate *appDelegate;
@property (assign, nonatomic) NSString *apiLoginResponseId;

@end

@implementation MasterViewController

@synthesize tableView, addGroupView, exploreLabel;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApiUpdate:)
                                                 name:@"groups_ready"
                                               object:nil];
    
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
    [self.tableView setContentInset:UIEdgeInsetsMake(tablePositionY, 0, 0, 0)];
}

- (void)didReceiveApiUpdate:(NSNotification *)notification
{
    self.connectionStatusText.text = @"Connected to Underplan!";
    self.connectedToMeteor = YES;

    if ([[notification name] isEqualToString:@"groups_ready"]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self._groups = [SharedApiClient getClient].collections[@"groups"];
        [self.tableView reloadData];
    }
    else if ([[notification name] isEqualToString:@"connected"])
    {
        // FIXME: just testing this here!!
        [self setLoggedInState];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SharedApiClient getClient].authDelegate = self;
    
    self.view = [[UIView alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];

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
    
    [self setupProductLabel];
    [self setupTableView];
    [self setupGroupView];
    [self setupLoginButton];
}

- (void)setupProductLabel
{
    // Add product name
    self.productLabel = [[UILabel alloc] init];
    self.productLabel.text = @"Underplan";
    self.productLabel.textAlignment = NSTextAlignmentCenter;
    self.productLabel.textColor = [UIColor underplanPrimaryDarkColor];
    self.productLabel.font = [UIFont fontWithName:@"LilyScriptOne-Regular" size:productNameHeight];
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
                                                                      metrics:@{@"lblHeight": [[NSNumber alloc] initWithInt:productNameHeight],
                                                                                @"lblPositionY": [[NSNumber alloc] initWithInt:productNamePositionY]}
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

- (void)setupTableView
{
    // Table View
    self.tableView = [[UITableView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setupGroupView
{
    self.addGroupView = [[UIView alloc] init];
    
    self.addGroupView.backgroundColor = [UIColor underplanPrimaryColor];
    self.addGroupView.layer.borderColor = [UIColor underplanPrimaryDarkColor].CGColor;
    self.addGroupView.layer.borderWidth = 1;
    self.addGroupView.layer.masksToBounds = YES;
    self.addGroupView.layer.cornerRadius = btnHeight/2;
    
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWebURL:)];
    [self.addGroupView addGestureRecognizer:tapGesture];
    [self.addGroupView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.addGroupView.alpha = 1.0f;
    [self.view addSubview:self.addGroupView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(addGroupView);
    
    NSString *format = @"H:|-(>=0)-[addGroupView(width)]-(>=0)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"width": [[NSNumber alloc] initWithInt:btnWidth]}
                                                                        views:viewsDictionary]];

    // Center the button horizontally with the parent view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addGroupView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    UILabel *btnLabel = [[UILabel alloc] init];
    btnLabel.text = @"Create your journey";
    btnLabel.textAlignment = NSTextAlignmentCenter;
    btnLabel.textColor = [UIColor whiteColor];
    btnLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:btnTextHeight];
    btnLabel.backgroundColor = [UIColor clearColor];
    [btnLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.addGroupView addSubview:btnLabel];
    
    viewsDictionary = NSDictionaryOfVariableBindings(btnLabel);
    
    format = @"H:|-(0)-[btnLabel(width)]-(0)-|";
    [self.addGroupView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:@{@"width": [[NSNumber alloc] initWithInt:btnWidth]}
                                                                        views:viewsDictionary]];

    format = @"V:|-(>=0)-[btnLabel(height)]-(>=0)-|";
    [self.addGroupView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"height": [[NSNumber alloc] initWithInt:btnTextHeight]}
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
                                                                   constant:btnTextHeight]];
    
    // Explore Label
    exploreLabel = [[UILabel alloc] init];
    exploreLabel.text = @"Or, Explore";
    exploreLabel.textColor = [UIColor whiteColor];
    exploreLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:exploreLblHeight];
    exploreLabel.backgroundColor = [UIColor clearColor];
    [exploreLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
//    self.exploreLabel.alpha = 0.0f;
    [self.view addSubview:exploreLabel];
    
    viewsDictionary = NSDictionaryOfVariableBindings(addGroupView, exploreLabel);
    
    format = @"V:|-(btnPositionY)-[addGroupView(btnHeight)]-(20)-[exploreLabel(lblHeight)]-(>=0)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"lblHeight": [[NSNumber alloc] initWithInt:exploreLblHeight],
                                                                                @"btnHeight": [[NSNumber alloc] initWithInt:btnHeight],
                                                                                @"btnPositionY": [[NSNumber alloc] initWithInt:btnPositionY]}
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

- (void)setupLoginButton
{
    self.loginButton = [UIButton buttonWithType: UIButtonTypeSystem];
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    [self.loginButton setTitleColor:[UIColor underplanPrimaryDarkColor] forState:UIControlStateNormal];

    [self.loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:self.loginButton];
    [self.view bringSubviewToFront:self.loginButton];

    NSString *format = @"H:|-(>=10)-[button]-(10)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"width": @200}
                                                                        views:@{@"button": self.loginButton}]];
    format = @"V:|-(5)-[button(height)]-(>=10)-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:@{@"height": @20}
                                                                        views:@{@"button": self.loginButton}]];
}

#pragma mark - DDPAuthDelegate

- (void)authenticationFailed:(NSString *)reason
{
    // Do something here...
}

- (void)setLoggedInState
{
    GTMOAuth2Authentication *auth;
    auth = [GoogleAuthViewController authForGoogleFromKeychainForName:kKeychainItemName
                                                                 clientID:@GOOGLE_AUTH_CLIENT_ID
                                                             clientSecret:@GOOGLE_AUTH_CLIENT_SECRET];
    
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if ([auth canAuthorize])
                         {
                             [self.loginButton setTitle:@"Sign out" forState:UIControlStateNormal];
                             
                             [SharedApiClient setAuth:auth];
                             [self authenticateWithApiServer];
                             
                             [self.loginButton removeTarget:self action:@selector(signInGoogle:) forControlEvents:UIControlEventTouchUpInside];
                             [self.loginButton addTarget:self action:@selector(signOutGoogle:) forControlEvents:UIControlEventTouchUpInside];
                        }
                         else
                         {
                             [self.loginButton setTitle:@"Sign in with Google" forState:UIControlStateNormal];
                             
                             [self.loginButton removeTarget:self action:@selector(signOutGoogle:) forControlEvents:UIControlEventTouchUpInside];
                             [self.loginButton addTarget:self action:@selector(signInGoogle:) forControlEvents:UIControlEventTouchUpInside];
                         }
                     }
                     completion:^(BOOL finished){}
                ];
}

- (void)signInGoogle:(id)sender
{
    NSString *scope = @"https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"; // scope for Google+ API
    
    GoogleAuthViewController *viewController;
    viewController = [[GoogleAuthViewController alloc] initWithScope:scope
                                                                clientID:@GOOGLE_AUTH_CLIENT_ID
                                                            clientSecret:@GOOGLE_AUTH_CLIENT_SECRET
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}

- (void)signOutGoogle:(id)sender
{
    [GoogleAuthViewController removeAuthFromKeychainForName:kKeychainItemName];
    
    GTMOAuth2Authentication *auth = [SharedApiClient getAuth];
    if (auth)
        [GoogleAuthViewController revokeTokenForGoogleAuthentication:auth];
    
    // notify api server we have logged out
    [[SharedApiClient getClient] sendWithMethodName:@"logout" parameters:nil];
    
    [self setLoggedInState];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        [SharedApiClient setAuth:nil];
    } else {
        [SharedApiClient setAuth:auth];
        [self authenticateWithApiServer];
    }
    [self setLoggedInState];
}

- (void)authenticateWithApiServer
{
    GTMOAuth2Authentication *auth = [SharedApiClient getAuth];
    
    NSString *token = auth.accessToken ? auth.accessToken : auth.refreshToken;
    NSArray *params = @[@{@"email": auth.userEmail, @"id": auth.userID}, token];
    self.apiLoginResponseId = [[SharedApiClient getClient] sendWithMethodName:@"loginGoogle"
                                                                   parameters:params
                                                             notifyOnResponse:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAuthenticateUser:)
                                                 name:[NSString stringWithFormat:@"response_%@", self.apiLoginResponseId]
                                               object:nil];
}

- (void)didAuthenticateUser:(NSNotification *)notification
{
    NSString *userId = notification.userInfo[@"userId"];
    if (userId)
    {
        [SharedApiClient getClient].userId = userId;
    }    
//    NSString *responseId = [NSString stringWithFormat:@"response_%@", self.apiLoginResponseId];
//    [self removeObserver:self forKeyPath:responseId];
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
    int proximity = -10;
    
    // return if exploreLabel at 0 => layout not complete
    if (!lblOffset)
        return;
    
    if (diff > proximity)
    {
        if (self.productLabel.alpha == 1.0f)
            [self fadeOutElementsWithAlpha:@[self.productLabel, self.loginButton]];
    }
    else
    {
        if (self.productLabel.alpha == 0.0f)
            [self fadeInElementsWithAlpha:@[self.productLabel, self.loginButton]];
    }
}

- (void)setFadeForGroupAddView:(int)scrollViewYOffset
{
    // Fade in / out group button and labels
//    int yOffset = scrollView.contentOffset.y;
    int lblOffset = self.exploreLabel.frame.origin.y + self.exploreLabel.frame.size.height;
    int diff = scrollViewYOffset + lblOffset;
    int proximity = -10;
    
    // return if exploreLabel at 0 => layout not complete
    if (!lblOffset)
        return;
    
    if (diff > proximity)
    {
        if (self.exploreLabel.alpha == 1.0f)
            [self fadeOutElementsWithAlpha:@[self.exploreLabel, self.addGroupView]];
    }
    else
    {
        if (self.exploreLabel.alpha == 0.0f)
            [self fadeInElementsWithAlpha:@[self.exploreLabel, self.addGroupView]];
    }
}

- (void)fadeOutElementsWithAlpha:(NSArray *)elements
{
    for (id element in elements)
    {
        [self fadeOutElementWithAlpha:element];
    }
}

- (void)fadeOutElementWithAlpha:(id)element
{
    // Fade out the label right away
    [UIView animateWithDuration:0.1
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if ([element respondsToSelector:@selector(alpha)])
                         {
                             [element setValue:@0 forKey:@"alpha"];
                         }
                     }
                     completion:nil];
}

- (void)fadeInElementsWithAlpha:(NSArray *)elements
{
    for (id element in elements)
    {
        [self fadeInElementWithAlpha:element];
    }
}

- (void)fadeInElementWithAlpha:(id)element
{
    // Fade out the label right away
    [UIView animateWithDuration:0.1
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if ([element respondsToSelector:@selector(alpha)])
                         {
                             [element setValue:@1 forKey:@"alpha"];
                         }
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
    Group *group = [[Group alloc] initWithId:self._groups[indexPath.row][@"_id"]];
    GroupItemViewCell *item = [[GroupItemViewCell alloc] init];
    
    return [item cellHeight:group.details withTitle:group.name];
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
