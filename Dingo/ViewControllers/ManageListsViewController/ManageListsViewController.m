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

@interface ManageListsViewController (){
    NSMutableArray *arraPastEventTickets;
    NSMutableArray *arraFutureEventTickets;
}
@property (nonatomic) NSUInteger firstSectionCellsCount;

@end

@implementation ManageListsViewController

#pragma amrk - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  NSMutableArray  *arraPastEventTicket= [NSMutableArray arrayWithArray:[[DataManager shared] tickets_BeforeDate:[NSDate date]]];
    NSMutableArray *arraFutureEventTicket=[NSMutableArray arrayWithArray:[[DataManager shared] tickets_AfterDate:[NSDate date]]];
    arraPastEventTickets=[NSMutableArray arrayWithArray:[self sortEvents:arraPastEventTicket]];
     arraFutureEventTickets=[NSMutableArray arrayWithArray:[self sortEvents:arraFutureEventTicket]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ZSLoadingView *loadingView =[[ZSLoadingView alloc] initWithLabel:@"Loading tickets ..."];
    [loadingView show];
    
    [[DataManager shared] userTicketsWithCompletion:^(BOOL finished) {
        NSArray* tickets = [[DataManager shared] userTickets];

        if (tickets.count == 0) {
            UILabel *lblNoTickets = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 260, 60)];
            lblNoTickets.text = @"You currently have no tickets for sale";
            lblNoTickets.textAlignment = NSTextAlignmentCenter;
            lblNoTickets.textColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1];
            lblNoTickets.font = [DingoUISettings fontWithSize:20];
            lblNoTickets.numberOfLines = 0;
            
            [self.view addSubview:lblNoTickets];
        }
        
       NSMutableArray *arraPastEventTicket= [NSMutableArray arrayWithArray:[[DataManager shared] tickets_BeforeDate:[NSDate date]]];
       NSMutableArray *arraFutureEventTicket=[NSMutableArray arrayWithArray:[[DataManager shared] tickets_AfterDate:[NSDate date]]];
        arraPastEventTickets=[NSMutableArray arrayWithArray:[self sortEvents:arraPastEventTicket]];
               arraFutureEventTickets=[NSMutableArray arrayWithArray:[self sortEvents:arraFutureEventTicket]];
        
        [self.tableView reloadData];
        [loadingView hide];
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return eventCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString * const sectionHeader = @"SectionHeaderView";
    NSString *title = section ? @"Up and coming events..." : @"Old listings...";
    return [SectionHeaderView buildWithTitle:title fromXibNamed:sectionHeader];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
       // NSUInteger index = indexPath.row;
        Ticket *data=nil;
        if (indexPath.section && [arraFutureEventTickets count]>0) {
            //index += self.firstSectionCellsCount;
            data=[arraFutureEventTickets objectAtIndex:indexPath.row];
        }else{
            data=[arraPastEventTickets objectAtIndex:indexPath.row];
        }
        
        //Ticket *data = [[DataManager shared] userTickets][index];
        
        NSDictionary *params = @{@"ticket_id":data.ticket_id,
                                 @"price":[data.price stringValue],
                                 @"available":@"0"
                                 };
        ZSLoadingView *loadingView =[[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
        [loadingView show];
        [WebServiceManager updateTicket:params photos:nil completion:^(id response, NSError *error) {
            NSLog(@"response %@", response);
            [loadingView hide];
            if (!error && [response[@"available"] intValue] == 0) {
                [[AppManager sharedManager].managedObjectContext deleteObject:data];
                //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             NSMutableArray  * arraPastEventTicket= [NSMutableArray arrayWithArray:[[DataManager shared] tickets_BeforeDate:[NSDate date]]];
                NSMutableArray *arraFutureEventTicket=[NSMutableArray arrayWithArray:[[DataManager shared] tickets_AfterDate:[NSDate date]]];
                arraPastEventTickets=[NSMutableArray arrayWithArray:[self sortEvents:arraPastEventTicket]];
                    arraFutureEventTickets=[NSMutableArray arrayWithArray:[self sortEvents:arraFutureEventTicket]];
                [self.tableView reloadData];

                
               
            }else{
                [WebServiceManager genericError];
            }
        }];
    }
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
   }

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section ) {
        if (arraFutureEventTickets.count == 0) {
            return 0;
        }
    } else {
        if (arraPastEventTickets.count == 0) {
            return 0;
        }
    }
    
    return sectionHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ) {
        return arraFutureEventTickets.count;
    } else {
        return arraPastEventTickets.count;
        //return self.firstSectionCellsCount;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return /*[[DataManager shared] eventsDateRange]*/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self buildEventCellForIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    Ticket *data=nil;
    if([segue.identifier isEqual:@"TicketDetailSegue"]) {
        NSIndexPath *selectedCellPath = [self.tableView indexPathForSelectedRow];
       // NSUInteger index = selectedCellPath.row;
        if (selectedCellPath.section && [arraFutureEventTickets count] ) {
            //index += self.firstSectionCellsCount;
            data=[arraFutureEventTickets objectAtIndex:selectedCellPath.row];
        }else{
            data=[arraPastEventTickets objectAtIndex:selectedCellPath.row];
        }
        
        //Ticket *data = [[DataManager shared] userTickets][index];

        TicketDetailViewController *vc = (TicketDetailViewController *)segue.destinationViewController;
        vc.ticket = data;
        if (selectedCellPath.section)
            vc.iseditable=true;
        else
            vc.iseditable=false;
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

#pragma mark - custom methods

-(NSArray *)sortEvents:(NSMutableArray *)unsortedArr{
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
    
   // NSUInteger index = path.row;
    if (path.section) {
         [cell buildWithTicketData:[arraFutureEventTickets objectAtIndex:path.row]];
       // index += self.firstSectionCellsCount;
    }else{
        [cell buildWithTicketData:[arraPastEventTickets objectAtIndex:path.row]];
    }
    
    //Ticket *data = [[DataManager shared] userTickets][index];
   
    return cell;
}

@end
