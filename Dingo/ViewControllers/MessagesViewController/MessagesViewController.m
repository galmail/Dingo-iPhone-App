//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "MessagesViewController.h"

#import "MessagesCell.h"
#import "DataManager.h"
#import "DingoUISettings.h"
#import "SectionHeaderView.h"
#import "WebServiceManager.h"
#import "ChatViewController.h"
#import "ZSLoadingView.h"
#import "HomeTabBarController.h"

@interface MessagesViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *groupedMessages;
    BOOL isNotFirstTime;
    
    
}

@end

@implementation MessagesViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    [self groupMessagesByUser];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
//    self.parentViewController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    
    [[DataManager shared] fetchMessagesWithCompletion:^(BOOL finished) {
        isNotFirstTime=true;
        [self groupMessagesByUser];
        [loadingView hide];
        [(HomeTabBarController*)self.tabBarController updateMessageCount];
        
    }];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
   
    [self.refreshControl beginRefreshing];
    

    [[DataManager shared] fetchMessagesWithCompletion:^(BOOL finished) {
        isNotFirstTime=true;
        [self groupMessagesByUser];
        [self.tableView reloadData];        [self.refreshControl endRefreshing];
        [(HomeTabBarController*)self.tabBarController updateMessageCount];
        
    }];
}

- (void)groupMessagesByUser {
    
    NSArray *allMessages = [[DataManager shared] allMessages];
    if (!allMessages.count) {
        if (allMessages.count == 0 && isNotFirstTime) {
            UILabel *lblNoMessages = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 260, 60)];
            lblNoMessages.text = @"You have no messages :(";
            lblNoMessages.textAlignment = NSTextAlignmentCenter;
            lblNoMessages.textColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1];
            lblNoMessages.font = [DingoUISettings fontWithSize:20];
            lblNoMessages.tag=6787;
            lblNoMessages.numberOfLines = 0;
            
            [self.view addSubview:lblNoMessages];
        }

    }else{
    groupedMessages = [NSMutableArray new];
        
    NSArray * ticketIDs = [allMessages valueForKeyPath:@"ticket_id"];
    NSSet *ticketsSet = [NSSet setWithArray:ticketIDs];
    ticketIDs = [ticketsSet allObjects];

    for (NSString *ticketID in ticketIDs) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticket_id == %@ && ticket_id.length > 0" ,ticketID];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO];
//        NSArray* msgArray = [allMessages filteredArrayUsingPredicate:predicate];
        NSArray* msgArray = [[DataManager shared] allMessagesFor:[AppManager sharedManager].userInfo[@"id"] ticketID:ticketID];

        
        if (msgArray.count > 0) {
             NSArray *sorted = [msgArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            [groupedMessages addObject:sorted[0]];
        }
    }
    
    groupedMessages = [[groupedMessages sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]]] mutableCopy];
    
    [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self removeNoMessage];

    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return messagesCellHeight;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groupedMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellId = @"MessagesCell";
   
    
    MessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    Message *msg = groupedMessages[indexPath.row];
    [cell buildWithData:msg];
    return cell;
    
    }

#pragma mark - custom methods
-(void)removeNoMessage{
    id lblNoMessage=[self.view viewWithTag:6787];
    if (lblNoMessage)
        [lblNoMessage removeFromSuperview];
    isNotFirstTime=false;
}

#pragma mark - UIAction

- (IBAction)edit:(UIBarButtonItem *)sender {
    BOOL isEditMode = self.tableView.editing;
    [sender setTitle:isEditMode ? @"Edit" : @"Done"];
    [self.tableView setEditing:!isEditMode animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    NSIndexPath *selectedCellPath = [self.tableView indexPathForSelectedRow];
    Message* data = groupedMessages[selectedCellPath.row];
    
    ChatViewController *vc = (ChatViewController *)segue.destinationViewController;
    
    Ticket *ticket = [[DataManager shared] ticketByID:data.ticket_id];

    NSString *userID = [[AppManager sharedManager].userInfo[@"id"] stringValue];
    if ([[ticket.user_id stringValue] isEqualToString:userID]) {
        if ([data.receiver_id isEqualToString:[ticket.user_id stringValue]]) {
            vc.receiverName = data.sender_name;
            vc.receiverID = data.sender_id;
        } else {
           vc.receiverName = data.receiver_name;
           vc.receiverID = data.receiver_id;
        }
    } else {
        if (!ticket) {
            
            if ([data.from_dingo integerValue]==1) {
                vc.receiverName = data.sender_name;
                vc.receiverID = data.sender_id;
            }else{
            vc.receiverName = data.receiver_name;
            vc.receiverID = data.receiver_id;
            }
        }else{

        vc.receiverName = ticket.user_name;
        vc.receiverID = [ticket.user_id stringValue];
        }
    }
    
    
   
    vc.ticket = ticket;
    
}

@end
