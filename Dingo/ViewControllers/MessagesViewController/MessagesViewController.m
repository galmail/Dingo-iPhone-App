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
        
        [[DataManager shared] userTicketsWithCompletion:^(BOOL finished) {
            [loadingView hide];
        }];
        
    }];
}

- (void)groupMessagesByUser {
    
    NSArray *allMessages = [[DataManager shared] allMessages];
    groupedMessages = [NSMutableArray new];
    
    NSNumber *userID = [AppManager sharedManager].userInfo[@"id"];
    
    NSArray * senderIDs = [allMessages valueForKeyPath:@"sender_id"];
    NSArray * receiverIDs = [allMessages valueForKeyPath:@"receiver_id"];
    
    NSMutableSet *set = [NSMutableSet new];
    [set addObjectsFromArray:senderIDs];
    [set addObjectsFromArray:receiverIDs];
    
    NSMutableArray *userIDs = [[set allObjects] mutableCopy];
    
    for (NSString *user_ID in userIDs) {
        if ([[userID stringValue] isEqualToString:user_ID]) {
            continue;
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sender_id == %@ || receiver_id == %@",user_ID, user_ID];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO];
        
        NSArray* msgArray = [allMessages filteredArrayUsingPredicate:predicate];
        if (msgArray.count>0) {
            NSArray *sorted = [msgArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            [groupedMessages addObject:sorted[0]];
        }
        
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return messagesCellHeight;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return sectionEventHeaderHeight;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSString *title = [[DataManager shared] allFriends][section * sectionCellsCount][@"event"];
//    return [SectionHeaderView buildWithTitle:title
//                                fromXibNamed:@"SectionEventHeaderView"];
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"Remove\nConversation";
//}

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
    vc.ticket = [[DataManager shared] ticketByID:msg.ticket_id];
    
}

@end
