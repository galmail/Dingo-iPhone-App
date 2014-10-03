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

@interface MessagesViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *groupedMessages;
}

@end

@implementation MessagesViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self groupMessagesByUser];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
//    self.parentViewController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    
    [[DataManager shared] fetchMessagesWithCompletion:^(BOOL finished) {
        [self groupMessagesByUser];
        [loadingView hide];
        
    }];
}

- (void)groupMessagesByUser {
    
    NSArray *allMessages = [[DataManager shared] allMessages];
    groupedMessages = [NSMutableArray new];
    
    NSArray * ticketIDs = [allMessages valueForKeyPath:@"ticket_id"];
    NSSet *ticketsSet = [NSSet setWithArray:ticketIDs];
    ticketIDs = [ticketsSet allObjects];

    for (NSString *ticketID in ticketIDs) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticket_id == %@ && ticket_id.length > 0" ,ticketID];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO];
        NSArray* msgArray = [allMessages filteredArrayUsingPredicate:predicate];
        
        if (msgArray.count > 0) {
             NSArray *sorted = [msgArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            [groupedMessages addObject:sorted[0]];
        }
    }
    
    
//    NSMutableSet *set = [NSMutableSet new];
//    [set addObjectsFromArray:senderIDs];
//    [set addObjectsFromArray:receiverIDs];
//    
//    NSMutableArray *userIDs = [[set allObjects] mutableCopy];
    
//    for (NSString *user_ID in userIDs) {
//        if ([[userID stringValue] isEqualToString:user_ID]) {
//            continue;
//        }
//
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sender_id == %@ || receiver_id == %@",user_ID, user_ID];
//        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO];
//        
//        NSArray* msgArray = [allMessages filteredArrayUsingPredicate:predicate];
//        if (msgArray.count>0) {
//            NSArray *sorted = [msgArray sortedArrayUsingDescriptors:@[sortDescriptor]];
//            
//            [groupedMessages addObject:sorted[0]];
//        }
//        
//    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
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
    Message* msg = groupedMessages[selectedCellPath.row];
    
    ChatViewController *vc = (ChatViewController *)segue.destinationViewController;
    Ticket *ticket = [[DataManager shared] ticketByID:msg.ticket_id];
    
    vc.ticket = ticket;
    
}

@end
