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

#import "ProposalCell.h"
#import "DataManager.h"
#import "DingoUISettings.h"
#import "ZSLoadingView.h"
#import "WebServiceManager.h"
#import <MapKit/MapKit.h>

@interface TicketsViewController () <UITableViewDelegate, UITableViewDataSource> {
    EventCell *eventCell;
    MKMapView *locationMapView;
}


@end

@implementation TicketsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];

    
    [[DataManager shared] allTicketsByEventID:self.eventData.event_id completion:^(BOOL finished) {
        
        [self.tableView reloadData];
        
        [[DataManager shared] allAlertsWithCompletion:^(BOOL finished) {
            NSArray *alertArray = [[DataManager shared] allAlerts];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_id == %@", self.eventData.event_id];
            NSArray *filteredArray = [alertArray filteredArrayUsingPredicate:predicate];
            eventCell.on = (filteredArray.count > 0);
        }];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    locationMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap:)];
    [locationMapView addGestureRecognizer:tap];
    
    [WebServiceManager addressToLocation:[DataManager eventLocation:self.eventData] completion:^(id response, NSError *error) {

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


-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    
    [self.refreshControl beginRefreshing];
    
    [[DataManager shared] allTicketsByEventID:self.eventData.event_id completion:^(BOOL finished) {
        
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        [[DataManager shared] allAlertsWithCompletion:^(BOOL finished) {
            NSArray *alertArray = [[DataManager shared] allAlerts];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_id == %@", self.eventData.event_id];
            NSArray *filteredArray = [alertArray filteredArrayUsingPredicate:predicate];
            eventCell.on = (filteredArray.count > 0);
        }];
    }];

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"indexPath row %d", indexPath.row);
//    return indexPath.row ? eventCellHeight : featureCellHeight;
    if (indexPath.row == 0) {
        return featureCellHeight;
    } else if (indexPath.row == 1) {
        return 80;
//        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return eventCellHeight;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager shared] allTicketsByEventID:self.eventData.event_id].count + 2;
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

    if (indexPath.row == 0) {
        return [self buildEventCell];
    } else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell addSubview:locationMapView];
        return cell;
        
    } else {
        return [self buildEventCellForIndex:indexPath.row - 2];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    if (index) {
        Ticket *data = [[DataManager shared] allTicketsByEventID:self.eventData.event_id][index-2];
        
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
        if (response) {
            
            if (sender.selected) {
                [AppManager showAlert:@"Ticket alert for this event has been added. When a new ticket is listed we'll let you know"];
            } else {
                [AppManager showAlert:@"Ticket alert removed."];
                
            }
            
            [[DataManager shared] addOrUpdateAlert:response];
        }
        [loadingView hide];
    }];
}

- (IBAction)addTicketsPressed:(UIButton *)sender {
    
    
    ListTicketsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListTicketsViewController"];
    viewController.event = self.eventData;
    viewController.ticket = [[Ticket alloc] initWithEntity:[NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
    
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
