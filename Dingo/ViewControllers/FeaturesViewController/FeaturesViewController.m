//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "FeaturesViewController.h"

#import "TicketCell.h"
#import "DataManager.h"
#import "DingoUISettings.h"
#import "DingoUtilites.h"
#import "SectionHeaderView.h"
#import "TicketsViewController.h"
#import "TicketDetailViewController.h"

@interface FeaturesViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FeaturesViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, dingoTabBarHeight, 0)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    
    [self.refreshControl beginRefreshing];
    
    [[DataManager shared] allEventsWithCompletion:^(BOOL finished) {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return featureCellHeight;
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[DataManager shared] featuredEventsGroupsCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager shared] featuredEventsCountWithGroupIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    NSDate *date = [[DataManager shared] featuredEventGroupDateByIndex:section];
    NSString *title = [DingoUtilites eventFormattedDate:date];
    static NSString * const sectionHeader = @"SectionHeaderView";
    return [SectionHeaderView buildWithTitle:title fromXibNamed:sectionHeader];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellId = @"FeatureCell";
    TicketCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    Event *data = [[DataManager shared] featuredEventDescriptionByIndexPath:indexPath];
    [cell buildWithData:data];
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    NSIndexPath *selectedCellPath = [self.tableView indexPathForSelectedRow];
    Event* event= [[DataManager shared] featuredEventDescriptionByIndexPath:selectedCellPath];
    
    if ([event.tickets intValue] > 1) {
        TicketsViewController *vc = (TicketsViewController *)segue.destinationViewController;
        vc.eventData = event;
    } else {
        // TODO: need to show ticket detail
        
        TicketsViewController *vc = (TicketsViewController *)segue.destinationViewController;
        vc.eventData = event;
    }
}

@end
