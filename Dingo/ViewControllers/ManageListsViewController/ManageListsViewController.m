//
//  ManageListsViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "ManageListsViewController.h"

#import "ManageListsCell.h"
#import "SectionHeaderView.h"
#import "DataManager.h"
#import "ECSlidingViewController.h"
#import "TicketDetailViewController.h"

@interface ManageListsViewController ()

@property (nonatomic) NSUInteger firstSectionCellsCount;

@end

@implementation ManageListsViewController

#pragma amrk - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[DataManager shared] userTicketsWithCompletion:^(BOOL finished) {
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return eventCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString * const sectionHeader = @"SectionHeaderView";
    NSString *title = section ? @"Up and coming events..." : @"Past events...";
    return [SectionHeaderView buildWithTitle:title fromXibNamed:sectionHeader];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return sectionHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) {
        return [[DataManager shared] ticketsAfterDate:[NSDate date]].count;
    } else {
        self.firstSectionCellsCount = [[DataManager shared] ticketsBeforeDate:[NSDate date]].count;
        return self.firstSectionCellsCount;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[DataManager shared] eventsDateRange];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self buildEventCellForIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqual:@"TicketDetailSegue"]) {
        NSIndexPath *selectedCellPath = [self.tableView indexPathForSelectedRow];
        NSUInteger index = selectedCellPath.row;
        if (selectedCellPath.section) {
            index += self.firstSectionCellsCount;
        }
        
        Ticket *data = [[DataManager shared] userTickets][index];

        TicketDetailViewController *vc = (TicketDetailViewController *)segue.destinationViewController;
        vc.ticket = data;
        vc.event = [[DataManager shared] eventByID:data.event_id];
    }
    
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActions

- (IBAction)edit:(UIBarButtonItem *)sender {
    BOOL isEditMode = self.tableView.editing;
    [sender setTitle:isEditMode ? @"Edit" : @"Done"];
    [self.tableView setEditing:!isEditMode animated:YES];
}

#pragma mark - Private

- (UITableViewCell *)buildEventCellForIndexPath:(NSIndexPath *)path {
    static NSString * const cellId = @"ManageListsCell";
    ManageListsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    NSUInteger index = path.row;
    if (path.section) {
        index += self.firstSectionCellsCount;
    }
    
    Ticket *data = [[DataManager shared] userTickets][index];
    [cell buildWithTicketData:data];
    return cell;
}

@end
