//
//  TicketAlertsViewController.m
//  Dingo
//
//  Created by Tigran Aslanyan on 21.08.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "TicketAlertsViewController.h"
#import "AddTicketAlertViewController.h"
#import "TicketAlertCell.h"
#import "DataManager.h"

@interface TicketAlertsViewController (){
    
    IBOutlet UIImageView *imgEmptyAlerts;
    IBOutlet UITableView *tblTicketAlerts;
    NSMutableArray * alertsArray;
}

@end

@implementation TicketAlertsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    alertsArray = [NSMutableArray arrayWithArray:[[DataManager shared] allAlerts]];
    imgEmptyAlerts.hidden = YES;
    tblTicketAlerts.hidden = NO;
    if (alertsArray.count==0) {
        imgEmptyAlerts.hidden = NO;
        tblTicketAlerts.hidden = YES;
    }
    [tblTicketAlerts reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addNewTicketAlert:(id)sender {
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString * const sectionHeader = @"SectionHeaderView";
//    NSString *title = section ? @"Up and coming events..." : @"Past events...";
//    return [SectionHeaderView buildWithTitle:title fromXibNamed:sectionHeader];
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[AppManager sharedManager].managedObjectContext deleteObject:alertsArray[indexPath.row]];
        [[DataManager shared] save];
        [alertsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDataSource

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return sectionHeaderHeight;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return alertsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self buildAlertCellForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddTicketAlertViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTicketAlertViewController"];
    viewController.alert = alertsArray[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}



#pragma mark - UIActions

//- (IBAction)edit:(UIBarButtonItem *)sender {
//    BOOL isEditMode = self.tableView.editing;
//    [sender setTitle:isEditMode ? @"Edit" : @"Done"];
//    [self.tableView setEditing:!isEditMode animated:YES];
//}


#pragma mark - Private

- (UITableViewCell *)buildAlertCellForIndexPath:(NSIndexPath *)path {
    static NSString * const cellId = @"TicketAlertCell";
    TicketAlertCell *cell = [tblTicketAlerts dequeueReusableCellWithIdentifier:cellId];
    
    
    
    Alert *data = alertsArray[path.row];
    [cell buildWithData:data];
    return cell;
}
@end