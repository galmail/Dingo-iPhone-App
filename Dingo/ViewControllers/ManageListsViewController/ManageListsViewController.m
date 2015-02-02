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
#import "ZSLoadingView.h"
#import "WebServiceManager.h"

@interface ManageListsViewController ()

@property (nonatomic) NSUInteger firstSectionCellsCount;

@end

@implementation ManageListsViewController

#pragma amrk - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.arraTickets = [self sortEvents:self.arraTickets];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.arraTickets.count == 0) {
		UILabel *lblNoTickets = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 260, 60)];
		
		if ([self.title isEqualToString:@"Selling"]) {
			lblNoTickets.text = @"You currently have no tickets for sale";
		} else if ([self.title isEqualToString:@"Sold"]) {
			lblNoTickets.text = @"You currently have no sold tickets";
		} else {
			lblNoTickets.text = @"You currently have no purchased tickets";
		}
		
		lblNoTickets.textAlignment = NSTextAlignmentCenter;
		lblNoTickets.textColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1];
		lblNoTickets.font = [DingoUISettings fontWithSize:20];
		lblNoTickets.numberOfLines = 0;
		
		[self.view addSubview:lblNoTickets];
	}

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return eventCellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.arraTickets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self buildEventCellForIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    Ticket *data=nil;
    if([segue.identifier isEqual:@"TicketDetailSegue"]) {
        NSIndexPath *selectedCellPath = [self.tableView indexPathForSelectedRow];
       data=[self.arraTickets objectAtIndex:selectedCellPath.row];

        TicketDetailViewController *vc = (TicketDetailViewController *)segue.destinationViewController;
        vc.ticket = data;
        if (selectedCellPath.section)
            vc.iseditable=true;
        else
            vc.iseditable=false;
            vc.event = [[DataManager shared] eventByID:data.event_id];
    }
    
}

#pragma mark - UIActions
- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - custom methods

-(NSArray *)sortEvents:(NSArray *)unsortedArr{
    NSArray *sortedArr1 = [NSArray array];
    sortedArr1=[unsortedArr sortedArrayUsingComparator:^NSComparisonResult(Ticket *obj1, Ticket *obj2){
        Event *event1=[[DataManager shared] eventByID:obj1.event_id];
        Event *event2=[[DataManager shared] eventByID:obj2.event_id];
        
        if ([event1.date compare:event2.date]==NSOrderedAscending) {
            return NSOrderedAscending;
        } else if ([event1.date compare:event2.date]==NSOrderedDescending) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
        
        
    }];
    return sortedArr1;
}

#pragma mark - Private

- (UITableViewCell *)buildEventCellForIndexPath:(NSIndexPath *)path {
    static NSString * const cellId = @"ManageListsCell";
    ManageListsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
	[cell buildWithTicketData:[self.arraTickets objectAtIndex:path.row]];
    return cell;
}

@end
