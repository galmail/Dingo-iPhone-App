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


@interface MyTicketsViewController ()

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)back:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	ManageListsViewController *vc = [segue destinationViewController];
	vc.title = segue.identifier;
	if ([segue.identifier isEqualToString:@"Selling"]) {
		//
	}
}


@end
