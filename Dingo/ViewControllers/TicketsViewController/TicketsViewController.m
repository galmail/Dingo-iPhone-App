//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "TicketsViewController.h"
#import "TicketDetailViewController.h"
#import "ListTicketsViewController.h"
#import "MapViewController.h"
#import "WebViewController.h"

#import "ProposalCell.h"
#import "DataManager.h"
#import "DingoUISettings.h"
#import "ZSLoadingView.h"
#import "WebServiceManager.h"
#import <MapKit/MapKit.h>

@interface TicketsViewController () <UITableViewDelegate, UITableViewDataSource> {
    EventCell *eventCell;
    MKMapView *locationMapView;
	UIView *noSellers;
}


@end

@implementation TicketsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];

	[self refreshInvoked:nil forState:0];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    locationMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap:)];
    [locationMapView addGestureRecognizer:tap];
    
    //**********Adding Arrow on the map for navigat full screen
    UIImageView *imgViewArrow=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_map.png"]];
    [imgViewArrow setFrame:CGRectMake(screenSize.width-30, CGRectGetMidY(locationMapView.frame)-13.5, 20, 27)];
    [locationMapView addSubview:imgViewArrow];
    
    
    [WebServiceManager addressToLocation:[DataManager eventLocation:self.eventData] completion:^(id response, NSError *error) {
        if (error) {
            [WebServiceManager handleError:error];
        }

        if ([response[@"status"] isEqualToString:@"OK"]) {
            NSArray *results = response[@"results"];
            if (results.count > 0) {
                NSDictionary *result = results[0];
                
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([result[@"geometry"][@"location"][@"lat"] doubleValue], [result[@"geometry"][@"location"][@"lng"] doubleValue]);
                MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
                MKCoordinateRegion region = {coord, span};
                [locationMapView setRegion:region];
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = coord;
                [locationMapView addAnnotation:annotation];
            }
        }
    }];
            
    [self.tableView reloadData];
}

#pragma mark -

-(void)refreshInvoked:(id)sender forState:(UIControlState)state {
    // this if allows us to call [self refreshInvoked:nil forState:0] to refresh data without showing the refreshControl ;)
    if (sender) [self.refreshControl beginRefreshing];
    
    [[DataManager shared] allTicketsByEventID:self.eventData.event_id completion:^(BOOL finished) {
		
		[self.tableView reloadData];
		
		//lets check if we have sellers
		if ([[DataManager shared] allTicketsByEventID:self.eventData.event_id].count > 0) {
			[self hideNoSellers];
		} else {
			[self showNoSellers];
		}
		
		if (sender) [self.refreshControl endRefreshing];
			
        [[DataManager shared] allAlertsWithCompletion:^(BOOL finished) {
            NSArray *alertArray = [[DataManager shared] allAlerts];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_id == %@", self.eventData.event_id];
            NSArray *filteredArray = [alertArray filteredArrayUsingPredicate:predicate];
            eventCell.on = (filteredArray.count > 0);
        }];
    }];
}

- (void)showNoSellers {
	CGFloat bottomOfTable = CGRectGetMaxY([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] frame]);
	noSellers = [[UILabel alloc] initWithFrame:CGRectMake(30, bottomOfTable + 40, 260, 100)];
	
	UILabel *lblNoSellers = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
	lblNoSellers.text = @"No sellers on Dingo :(";
	lblNoSellers.textAlignment = NSTextAlignmentCenter;
	lblNoSellers.textColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1];
	lblNoSellers.font = [DingoUISettings fontWithSize:20];
	lblNoSellers.numberOfLines = 0;
	[noSellers addSubview:lblNoSellers];
	
	UIButton *btnNoSellers = [UIButton buttonWithType:UIButtonTypeCustom];
	btnNoSellers.frame = CGRectMake(0, 60, 260, 30);
	[btnNoSellers setTitle: @"But you can buy tickets here >" forState:UIControlStateNormal];
	[btnNoSellers setTitleColor:[UIColor colorWithRed:(170/255.0) green:(170/255.0) blue:(170/255.0) alpha:1] forState:UIControlStateNormal];
	btnNoSellers.titleLabel.textAlignment = NSTextAlignmentCenter;
	btnNoSellers.titleLabel.font = [DingoUISettings fontWithSize:20];
	[btnNoSellers addTarget:self action:@selector(buyTicket:) forControlEvents:UIControlEventTouchUpInside];
	[noSellers addSubview:btnNoSellers];
	
	[self.view addSubview:noSellers];
}

- (void)hideNoSellers {
	[noSellers removeFromSuperview];
}

- (void)buyTicket:(id)sender {
	//setup action here
	
	NSLog(@"woriywriyu");
	DLog(@"primary_ticket_seller_url: %@", self.eventData.primary_ticket_seller_url);
	[self performSegueWithIdentifier:@"WebSegue" sender:self];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"indexPath row %d", indexPath.row);
//    return indexPath.row ? eventCellHeight : featureCellHeight;
	
//old
//    if (indexPath.row == 0) {
//        return featureCellHeight;
//    } else if (indexPath.row == 1) {
//        return 80;
////        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
//    } else {
//        return eventCellHeight;
//    }
	
	//new
	switch (indexPath.row) {
		case 0:
			return featureCellHeight;
			break;
		case 1:
			return 80;
			break;
		case 2:
			return 40;
			break;
		default:
			return eventCellHeight;
			break;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[DataManager shared] allTicketsByEventID:self.eventData.event_id].count + 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSUInteger index = indexPath.row;
//    if (index) {
//        NSLog(@"IndexPath 1 %d", indexPath.row);
//        return [self buildEventCellForIndex:indexPath.row - 1];
//    } else {
//        NSLog(@"IndexPath 2 %d", indexPath.row);
//        return [self buildEventCell];
//    }

//old
//    if (indexPath.row == 0) {
//        return [self buildEventCell];
//    } else if (indexPath.row == 1) {
//        static NSString *CellIdentifier = @"cell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        [cell addSubview:locationMapView];
//        return cell;
//        
//    } else {
//        return [self buildEventCellForIndex:indexPath.row - 2];
//    }
	
//new
	switch (indexPath.row) {
		case 0:
			return [self buildEventCell];
			break;
		case 1: {
			static NSString *CellIdentifier = @"cell";
			//UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			[cell addSubview:locationMapView];
			return cell;
			break;
		}
		case 2:
			return [tableView dequeueReusableCellWithIdentifier:@"sellers_cell"];
			break;
		default:
			return [self buildEventCellForIndex:indexPath.row - 3];
			break;
	}
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSUInteger index = indexPath.row;
    if (index > 2) {
        Ticket *data = [[DataManager shared] allTicketsByEventID:self.eventData.event_id][index-3];
        
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
                             @"price": @99999,
                             @"description": self.eventData.name
                             };
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait ..."];
    [loadingView show];
    [WebServiceManager createAlert:params completion:^(id response, NSError *error) {
        [loadingView hide];
        if (response) {
            
            if (sender.selected) {
                [AppManager showAlert:@"Ticket alert for this event has been added. When a new ticket is listed we'll let you know"];
            } else {
                [AppManager showAlert:@"Ticket alert removed."];
                
            }
            
            [[DataManager shared] addOrUpdateAlert:response];
        }else if (error){
            [WebServiceManager handleError:error];
        }
        
    }];
}

- (IBAction)addTicketsPressed:(UIButton *)sender {
    
    
    ListTicketsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListTicketsViewController"];
    
    Ticket *ticket = [[Ticket alloc] initWithEntity:[NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
    [ticket setPrice:nil];
    [ticket setFace_value_per_ticket:nil];
    [ticket setNumber_of_tickets:nil];
    
    Event *tempEvent = [[Event alloc] initWithEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
        
    tempEvent.address = self.eventData.address;
    tempEvent.category_id = self.eventData.category_id;
    tempEvent.city = self.eventData.city;
    tempEvent.date = self.eventData.date;
    tempEvent.endDate = self.eventData.endDate;
    tempEvent.event_desc = self.eventData.event_desc;
    tempEvent.event_id = self.eventData.event_id;
    tempEvent.featured = self.eventData.featured;
    tempEvent.fromPrice = self.eventData.fromPrice;
    tempEvent.name = self.eventData.name;
    tempEvent.postalCode = self.eventData.postalCode;
    tempEvent.test = self.eventData.test;
    tempEvent.tickets = self.eventData.tickets;
    tempEvent.thumb = nil;
    tempEvent.thumbUrl = nil;

    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_event_paymentOptions"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_event_deliveryOptions"];
    [[NSUserDefaults standardUserDefaults] setObject:self.eventData.event_id forKey:@"kDingo_event_event_id"];
    [[NSUserDefaults standardUserDefaults] setObject:self.eventData.category_id forKey:@"kDingo_event_categoryID"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    viewController.event = tempEvent;
    viewController.ticket = ticket;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapOnMap:(UIGestureRecognizer *)gesture{
    [self performSegueWithIdentifier:@"MapSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"MapSegue"]) {
        
        UINavigationController *navController = segue.destinationViewController;
        MapViewController *vc = navController.viewControllers[0];
        vc.event = self.eventData;
		return;
    }
	
	if ([segue.identifier isEqual:@"WebSegue"]) {
		
		UINavigationController *navController = segue.destinationViewController;
		WebViewController *vc = navController.viewControllers[0];
		vc.event = self.eventData;
		return;
	}
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
