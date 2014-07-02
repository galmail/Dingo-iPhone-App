//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "OffersViewController.h"

#import "DataManager.h"
#import "DingoUISettings.h"
#import "SectionHeaderView.h"
#import "OffersCell.h"

@interface OffersViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSIndexPath *selectedOffer;

@end

@implementation OffersViewController

#pragma mark - Clear Up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedOffer = [NSIndexPath indexPathForRow:-1 inSection:-1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offerChanged:)
                                                 name:OfferCellDidChangeAcceptedStateNotification
                                               object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.parentViewController.navigationItem.titleView = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return offersCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [[DataManager shared] offersGroupTitleByIndex:section];
    return [SectionHeaderView buildWithTitle:title
                                fromXibNamed:@"SectionEventHeaderView"];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return sectionEventHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager shared] offersCountWithGroupIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[DataManager shared] offersGroupsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OffersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OffersCell"];
    NSDictionary *dict = [[DataManager shared] offerDescriptionByIndexPath:indexPath];
    cell.icon = [UIImage imageNamed:dict[@"icon"]];
    cell.name = dict[@"name"];
    cell.offerAccepted = [indexPath compare:self.selectedOffer] == NSOrderedSame;
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

#pragma mark - Observer

- (void)offerChanged:(NSNotification *)notif {
    self.selectedOffer = [self.tableView indexPathForCell:notif.object];
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
