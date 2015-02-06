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

@property (nonatomic, retain) NSMutableArray *arraTickets;

@end

@implementation ManageListsViewController

- (void)loadTickets {
	if ([self.title isEqualToString:@"Selling"]) {
		self.arraTickets = [self sortEvents:[[DataManager shared] ticketsSelling]];
	}
	if ([self.title isEqualToString:@"Sold"]) {
		self.arraTickets = [self sortEvents:[[DataManager shared] ticketsSold]];
	}
	if ([self.title isEqualToString:@"Purchased"]) {
		self.arraTickets = [self sortEvents:[[DataManager shared] ticketsPurchased]];
	}
}

#pragma amrk - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
		
	//hide the edit button for sold and purchased and set it up as edit button for selling
	if ([self.title isEqualToString:@"Selling"]) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.editButtonItem.tintColor = [UIColor whiteColor]; //this is silly, but needed nonetheless
	} else	{
		self.navigationItem.rightBarButtonItem = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self loadTickets];
	
	if (self.arraTickets.count == 0) {
		UIView *bg = [[UIView alloc] initWithFrame:self.view.bounds];
		bg.backgroundColor = [UIColor whiteColor];
		self.view = bg;
		
		UILabel *lblNoTickets = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 260, 60)];
		
		if ([self.title isEqualToString:@"Selling"]) {
			lblNoTickets.text = @"You currently have no tickets for sale.";
		} else if ([self.title isEqualToString:@"Sold"]) {
			lblNoTickets.text = @"You haven't sold any tickets.";
		} else {
			lblNoTickets.text = @"You haven't purchased any tickets.";
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
	if ([self.title isEqualToString:@"Selling"]) return YES;
	else return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		Ticket *data = [self.arraTickets objectAtIndex:indexPath.row];
		NSDictionary *params = @{@"ticket_id":data.ticket_id,
								 @"price":[data.price stringValue],
								 @"available":@"0"
								 };
		ZSLoadingView *loadingView =[[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
		[loadingView show];
		[WebServiceManager updateTicket:params photos:nil completion:^(id response, NSError *error) {
			NSLog(@"MLVC response %@", response);
			[loadingView hide];
			if (!error && [response[@"available"] intValue] == 0) {
				[[AppManager sharedManager].managedObjectContext deleteObject:data];
				
				[self.arraTickets removeObjectAtIndex:indexPath.row];
				[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
				
			}else{
				[WebServiceManager handleError:error];
			}
		}];
	}
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
        if ([self.title isEqualToString:@"Selling"])
            vc.iseditable=true;
        else
            vc.iseditable=false;
            vc.event = [[DataManager shared] eventByID:data.event_id];
    }
    
}

#pragma mark - UIActions
- (IBAction)back {
	[self.delegate updateMyTicketsViewControllerButtons];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - custom methods

-(NSMutableArray *)sortEvents:(NSArray *)unsortedArr{
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
    return sortedArr1.mutableCopy;
}

#pragma mark - Private

- (UITableViewCell *)buildEventCellForIndexPath:(NSIndexPath *)path {
    static NSString * const cellId = @"ManageListsCell";
    ManageListsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
	[cell buildWithTicketData:[self.arraTickets objectAtIndex:path.row]];
    return cell;
}

@end
