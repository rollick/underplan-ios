//
//  CommentsViewController.m
//  Underplan
//
//  Created by Mark Gallop on 25/07/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "CommentsViewController.h"
#import "SharedApiClient.h"

#import "UnderplanCommentItemCell.h"

#import "User.h"
#import "Comment.h"
#import "Activity.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Underplan.h"

@interface CommentsViewController ()

@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) Activity *activity;

@end

@implementation CommentsViewController

@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.view.backgroundColor = [UIColor underplanBgColor];
    self.tableView.backgroundColor = [UIColor underplanBgColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Fix the scrollview being behind tabbar
    if (self.tabBarController) {
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.bottom = self.tabBarController.tabBar.frame.size.height;
        self.tableView.contentInset = inset;
    }
    
    if (self.navigationController) {
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top = self.navigationController.navigationBar.frame.size.height + 20.0f; // 20.0f for the status bar
        self.tableView.contentInset = inset;
        
        CGPoint topOffset = CGPointMake(0, -inset.top);
        [self.tableView setContentOffset:topOffset animated:YES];
    }
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"activity"]) {
        [self setActivity:[change objectForKey:NSKeyValueChangeNewKey]];
    }
    
    if ([keyPath isEqual:@"comments"]) {
        [self setComments:[change objectForKey:NSKeyValueChangeNewKey]];
        
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated

{
    [super viewWillAppear:animated];

    self.navigationItem.title = @"Comments";

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UnderplanCommentItemCell class] forCellReuseIdentifier:@"Comment"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(comments)]) {
        [self setComments:[self.delegate comments]];
    }
    [self.tableView reloadData];
}

-(void)dealloc
{
    self.tableView.delegate = nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *_comment = _comments[indexPath.row];
    
    Comment *comment = [[Comment alloc] initWithId:_comment[@"_id"]];

    UnderplanCommentItemCell *cell = [[UnderplanCommentItemCell alloc] init];
    return [cell cellHeight:comment.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnderplanCommentItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Comment" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *_comment = _comments[indexPath.row];
    
    Comment *comment = [[Comment alloc] initWithId:_comment[@"_id"]];
    
    // Fetch owner
    User *owner = [[User alloc] initWithId:comment.ownerId];
    
    // Set the profile image
    // TODO: Maybe the activity cell needs to have a custom view which can
    //       be notified when the owner details are available....
    
    // Set the owners name as the title
    cell.detailsView.title.text = owner.profile[@"name"];
    
    // Set the owners profile picture
    NSString *profileImageUrl = [owner profileImageUrl:@75];
    
    [cell.detailsView.image setImageWithURL:[NSURL URLWithString:profileImageUrl]
                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    // Set the info field - date and location
    NSString *created;
    if([comment.created isKindOfClass:[NSMutableDictionary class]])
    {
        double dateDouble = [comment.created[@"$date"] doubleValue];
        dateDouble = dateDouble/1000;
        NSDate *dateCreated = [NSDate dateWithTimeIntervalSince1970:dateDouble];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy 'at' HH:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:dateCreated];
        
        created = formattedDateString;
    }
    else
    {
        created = @"-";
    }
    
    cell.detailsView.subTitle.text = created;
    cell.mainText.text = comment.text;

    self.tableView.backgroundColor = [UIColor underplanBgColor];
    
    return cell;
}

@end
