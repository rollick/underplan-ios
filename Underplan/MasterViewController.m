//
//  MasterViewController.m
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "MasterViewController.h"
#import "GroupViewController.h"
#import "UnderplanAppDelegate.h"
#import "UIViewController+UnderplanApiNotifications.h"
#import "SharedApiClient.h"
#import "GroupItemViewCell.h"

#import "Group.h"

#import "UIColor+Underplan.h"

@interface MasterViewController ()

@property (assign, nonatomic) BOOL connectedToMeteor;
@property (strong, nonatomic) NSMutableArray *_groups;
@property (assign, nonatomic) UnderplanAppDelegate *appDelegate;

@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Underplan";
//    self.navigationController.toolbar.translucent = YES;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    [self.tableView registerClass:[GroupItemViewCell class] forCellReuseIdentifier:@"Group"];
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
    

    [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryColor]];
    [[UITabBar appearance] setTintColor:[UIColor underplanPrimaryColor]];
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    }

    UIBarButtonItem *reconnectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reconnectSocket)];
    self.navigationItem.rightBarButtonItem = reconnectButton;
    
    self.view = [[UIView alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.view.backgroundColor = [UIColor underplanPanelColor];
    self.tableView.backgroundColor = [UIColor underplanBgColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Group" forIndexPath:indexPath];
    
    Group *group = [[Group alloc] initWithId:self._groups[indexPath.row][@"_id"]];
    
    cell.title.text = group.name;
    cell.description.text = group.details;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self._groups removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary *group = self._groups[indexPath.row];
//    self.groupViewController.group = group;

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