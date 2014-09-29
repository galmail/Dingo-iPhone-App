//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "TicketsViewController.h"
#import "TicketDetailViewController.h"

#import "ProposalCell.h"
#import "DataManager.h"
#import "DingoUISettings.h"
#import "ZSLoadingView.h"
#import "WebServiceManager.h"

@interface TicketsViewController () <UITableViewDelegate, UITableViewDataSource> {
    EventCell *eventCell;
}

@end

@implementation TicketsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    ZSLoadingView *loadingView =[[ZSLoadingView alloc] initWithLabel:@"Loading tickets ..."];
    [loadingView show];
    [[DataManager shared] allTicketsByEventID:self.eventData.event_id completion:^(BOOL finished) {
        
        [self.tableView reloadData];
        
        [[DataManager shared] allAlertsWithCompletion:^(BOOL finished) {
            
            [loadingView hide];
            NSArray *alertArray = [[DataManager shared] allAlerts];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_id == %@", self.eventData.event_id];
            NSArray *filteredArray = [alertArray filteredArrayUsingPredicate:predicate];
            eventCell.on = (filteredArray.count > 0);
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row ? eventCellHeight : featureCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager shared] allTicketsByEventID:self.eventData.event_id].count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    if (index) {
        return [self buildEventCellForIndex:indexPath.row - 1];
    } else {
        return [self buildEventCell];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    if (index) {
        Ticket *data = [[DataManager shared] allTicketsByEventID:self.eventData.event_id][index-1];
        
        TicketDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailViewController"];
        viewController.event = self.eventData;
        viewController.ticket = data;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - Navigation

- (IBAction)bellOnOff:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    // Update Alert
    NSDictionary *params = @{@"event_id":self.eventData.event_id,
                             @"on":@(sender.selected),
                             @"price": self.eventData.fromPrice
                             };
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait ..."];
    [loadingView show];
    [WebServiceManager createAlert:params completion:^(id response, NSError *error) {
        if (response) {
            [[DataManager shared] addOrUpdateAlert:response];
        }
        [loadingView hide];
    }];
}


- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private

- (UITableViewCell *)buildEventCellForIndex:(NSUInteger)index {
    static NSString * const ticketsCellName = @"ProposalCell";
    ProposalCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ticketsCellName];    
    Ticket *data = [[DataManager shared] allTicketsByEventID:self.eventData.event_id][index];
    [cell buildWithTicketData:data];
    return cell;
}

- (UITableViewCell *)buildEventCell {
    static NSString * const ticketsCellName = @"EventCell";
    eventCell = [self.tableView dequeueReusableCellWithIdentifier:ticketsCellName];
    [eventCell buildWithData:self.eventData];
    return eventCell;
}

@end
