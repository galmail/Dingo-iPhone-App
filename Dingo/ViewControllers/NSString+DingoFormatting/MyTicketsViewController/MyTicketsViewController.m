//
//  MyTicketsViewController.m
//  Dingo
//
//  Created by Nonnus on 27/01/15.
//  Copyright (c) 2015 Dingo. All rights reserved.
//

#import "MyTicketsViewController.h"
#import "ZSLoadingView.h"
#import "WebServiceManager.h"
#import "ManageListsViewController.h"
#import "DataManager.h"


@interface MyTicketsViewController () <ManageListsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblSelling;
@property (strong, nonatomic) IBOutlet UILabel *lblSold;
@property (strong, nonatomic) IBOutlet UILabel *lblPurchased;

@end

@implementation MyTicketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblSelling.font = [DingoUISettings fontWithSize:18];
	self.lblSold.font = [DingoUISettings fontWithSize:18];
	self.lblPurchased.font = [DingoUISettings fontWithSize:18];
	
	ZSLoadingView *loadingView =[[ZSLoadingView alloc] initWithLabel:@"Loading tickets ..."];
	[loadingView show];
	[[DataManager shared] userTicketsWithCompletion:^(BOOL finished) {
		[self updateMyTicketsViewControllerButtons];
		[loadingView hide];
	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)updateMyTicketsViewControllerButtons {
	NSInteger ticketsSelling = [[DataManager shared] ticketsSelling].count;
	if (ticketsSelling > 0) {
		self.lblSelling.text = [NSString stringWithFormat:@"Selling (%li)", (long)ticketsSelling];
	} else {
		self.lblSelling.text = @"Selling";
	}
	NSInteger ticketsSold = [[DataManager shared] ticketsSold].count;
	if (ticketsSold > 0) {
		self.lblSold.text = [NSString stringWithFormat:@"Sold (%li)", (long)ticketsSold];
	} else {
		self.lblSold.text = @"Sold";
	}
	NSInteger ticketsPurchased = [[DataManager shared] ticketsPurchased].count;
	if (ticketsPurchased > 0) {
		self.lblPurchased.text = [NSString stringWithFormat:@"Purchased (%li)", (long)ticketsPurchased];
	} else {
		self.lblPurchased.text = @"Purchased";
	}
}


#pragma mark - UI

- (IBAction)back:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	ManageListsViewController *vc = [segue destinationViewController];
	vc.title = segue.identifier;
	if ([segue.identifier isEqualToString:@"Selling"]) {
		vc.delegate = self;
		vc.tickets = [[DataManager shared] ticketsSelling];
		return;
	}
	if ([segue.identifier isEqualToString:@"Sold"]) {
		vc.tickets = [[DataManager shared] ticketsSold];
		return;
	}
	if ([segue.identifier isEqualToString:@"Purchased"]) {
		vc.tickets = [[DataManager shared] ticketsPurchased];
		return;
	}
}


@end
