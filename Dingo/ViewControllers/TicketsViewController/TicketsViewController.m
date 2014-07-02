//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "TicketsViewController.h"

#import "ProposalCell.h"
#import "DataManager.h"
#import "DingoUISettings.h"

@interface TicketsViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation TicketsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row ? eventCellHeight : featureCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager shared] allTicketsByEventName:self.eventData[@"name"]].count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    if (index) {
        return [self buildEventCellForIndex:indexPath.row - 1];
    } else {
        return [self buildEventCell];
    }
    
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private

- (UITableViewCell *)buildEventCellForIndex:(NSUInteger)index {
    static NSString * const ticketsCellName = @"ProposalCell";
    ProposalCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ticketsCellName];    
    NSDictionary *data = [[DataManager shared] allTicketsByEventName:self.eventData[@"name"]][index];
    [cell buildWithData:data];
    return cell;
}

- (UITableViewCell *)buildEventCell {
    static NSString * const ticketsCellName = @"EventCell";
    EventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ticketsCellName];
    [cell buildWithData:self.eventData];
    return cell;
}

@end
