//
//  UnderplanMasterViewController.m
//  Underplan
//
//  Created by Mark Gallop on 23/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanMasterViewController.h"
#import "UnderplanGroupViewController.h"
#import "UnderplanAppDelegate.h"

#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"

#import "MeteorClient.h"

@interface UnderplanMasterViewController ()

@property (assign, nonatomic) BOOL connectedToMeteor;
@property (strong, nonatomic) NSMutableArray *_groups;
@property (assign, nonatomic) UnderplanAppDelegate *appDelegate;

@end

@implementation UnderplanMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Underplan";

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
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
    if([[notification name] isEqualToString:@"ready"])
    {
        self.connectionStatusText.text = @"Connected to Underplan!";
        self.connectedToMeteor = YES;
        
        self._groups = self.meteor.collections[@"groups"];
        [self.tableView reloadData];
    } else if([[notification name] isEqualToString:@"added"]) {
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor colorFromHexCode:@"1f4100"]
                                  highlightedColor:[UIColor colorFromHexCode:@"373737"]
                                      cornerRadius:3
                                   whenContainedIn:[UINavigationBar class], nil];
    
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: [UIFont boldFlatFontOfSize:18],
                                                                    UITextAttributeTextColor: [UIColor whiteColor]};
    
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor colorFromHexCode:@"008000"]];

    
    UnderplanAppDelegate *appDelegate = (UnderplanAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.meteor = appDelegate.meteor;
    
    self._groups = self.meteor.collections[@"groups"];
    [self.tableView reloadData];

	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *reconnectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reconnectSocket)];
    self.navigationItem.rightBarButtonItem = reconnectButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reconnectSocket
{
    // Only reconnect if the connection is closed
    if(self.meteor.ddp.webSocket.readyState == 3) {
        // FIXME:   Do we need to invalidate the collections
        //          before reconnecting?? Seems to duplicate the entries
        //          if we don't.
        [self.meteor resetCollections];
        [self.meteor.ddp connectWebSocket];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Group";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *group = self._groups[indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:100];
    name.text = group[@"name"];

    UILabel *description = (UILabel *)[cell viewWithTag:101];
    description.text = group[@"description"];
    
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDictionary *group = self._groups[indexPath.row];
        self.groupViewController.group = group;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showGroup"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *object = self._groups[indexPath.row];
        [[segue destinationViewController] setGroup:object];
        [[segue destinationViewController] setMeteor:self.meteor];
    }
}

@end
