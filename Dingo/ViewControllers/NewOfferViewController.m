//
//  NewOfferViewController.m
//  Dingo
//
//  Created by Asatur Galstyan on 9/16/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "NewOfferViewController.h"
#import "ZSTextField.h"

@interface NewOfferViewController () {
    
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UILabel *lblNumber;
    __weak IBOutlet UILabel *lblPice;
    __weak IBOutlet UILabel *lblTotal;
    __weak IBOutlet ZSTextField *txtNumber;
    __weak IBOutlet ZSTextField *txtPrice;
    __weak IBOutlet ZSTextField *txtTotal;
}

@end

@implementation NewOfferViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirm:(id)sender {

}


@end
