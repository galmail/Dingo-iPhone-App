//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "EventsViewController.h"

#import "TicketCell.h"
#import "CategorySelectionCell.h"
#import "DataManager.h"
#import "DingoUtilites.h"
#import "SectionHeaderView.h"
#import "TicketsViewController.h"
#import "DingoUISettings.h"

static const CGSize iconSize = {28, 32};
static const CGFloat categoriesHeight = 140;

@implementation EventsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.parentViewController.navigationItem.titleView = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section ? eventCellHeight : categoriesHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!section)  {
        return nil;
    }
    
    NSDate *date = [[DataManager shared] eventGroupDateByIndex:section - 1];
    NSString *title = [DingoUtilites eventFormattedDate:date];
    static NSString * const sectionHeader = @"SectionHeaderView";
    return [SectionHeaderView buildWithTitle:title fromXibNamed:sectionHeader];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) {
        return 0;
    }
    
    return sectionHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        return 1;
    }
    
    return [[DataManager shared] eventsCountWithGroupIndex:section - 1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[DataManager shared] eventsGroupsCount] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
        return [self buildCategoriesCell];
    }
    
    NSIndexPath *path = [self adjustedPath:indexPath];
    return [self buildEventCellForIndexPath:path];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TicketsViewController *vc = (TicketsViewController *)segue.destinationViewController;
    NSIndexPath *selectedCellPath = [self adjustedPath:[self.tableView indexPathForSelectedRow]];
    vc.eventData = [[DataManager shared] eventDescriptionByIndexPath:selectedCellPath];
}

#pragma mark - Private

- (void)setupNavigationBar {
    UIImageView *navigationImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, iconSize.width, iconSize.height)];
    navigationImage.image = [UIImage imageNamed:@"dingo_logo.png"];
    
    UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize.width, iconSize.height)];
    [workaroundImageView addSubview:navigationImage];
    self.parentViewController.navigationItem.titleView = workaroundImageView;
}

- (UITableViewCell *)buildEventCellForIndexPath:(NSIndexPath *)path {
    static NSString * const cellId = @"TicketsCell";
    TicketCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    [cell loadUIFromXib];
    
    NSDictionary *data = [[DataManager shared] eventDescriptionByIndexPath:path];
    [cell buildWithData:data];
    return cell;
}

- (UITableViewCell *)buildCategoriesCell {
    static NSString * const cellId = @"CategoriesCell";
    CategorySelectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    [cell buildByUserPreferences];
    return cell;
}

- (NSIndexPath *)adjustedPath:(NSIndexPath *)path {
    return [NSIndexPath indexPathForRow:path.row inSection:path.section - 1];
}

@end
