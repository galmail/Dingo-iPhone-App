//
//  SearchResultsViewController.m
//  Dingo
//
//  Created by logan on 6/18/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "TicketsViewController.h"

#import "TicketCell.h"
#import "DataManager.h"
#import "DingoUtilites.h"
#import "SectionHeaderView.h"
#import "DingoUISettings.h"

@implementation SearchResultsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (self.searchedEvents.count==0) {
        UILabel * lblNoResults = [[UILabel alloc] initWithFrame:CGRectMake(100, 70, 120, 30)];
        lblNoResults.textColor = [UIColor grayColor];
        lblNoResults.text = @"No Results Found";
        lblNoResults.font = [DingoUISettings fontWithSize:16];
        [self.tableView addSubview:lblNoResults];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return eventCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDate *date = [[DataManager shared] eventFromSearchGroupDateByIndex:section Events:self.searchedEvents];
    NSString *title = [DingoUtilites eventFormattedDate:date];
    static NSString * const sectionHeader = @"SectionHeaderView";
    return [SectionHeaderView buildWithTitle:title fromXibNamed:sectionHeader];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return sectionHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager shared] eventsFromSearchCountWithGroupIndex:section Events:self.searchedEvents];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[DataManager shared] eventsFromSearchGroupsCount:self.searchedEvents];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self buildEventCellForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TicketsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TicketsViewController"];
    vc.eventData = [[DataManager shared] eventFromSearchDescriptionByIndexPath:indexPath Events:self.searchedEvents];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"SearchEventDetail"]) {
    
        TicketsViewController *vc = (TicketsViewController *)segue.destinationViewController;
        
    }
}

#pragma mark - Private

- (UITableViewCell *)buildEventCellForIndexPath:(NSIndexPath *)path {
    static NSString * const cellId = @"TicketCell";
    TicketCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    [cell loadUIFromXib];
    
    Event *data = [[DataManager shared] eventFromSearchDescriptionByIndexPath:path Events:self.searchedEvents];
    [cell buildWithData:data];
    return cell;
}

@end