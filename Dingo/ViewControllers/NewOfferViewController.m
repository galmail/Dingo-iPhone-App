//
//  NewOfferViewController.m
//  Dingo
//
//  Created by Asatur Galstyan on 9/16/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "NewOfferViewController.h"
#import "ZSTextField.h"
#import "ZSLoadingView.h"
#import "DingoUISettings.h"
#import "WebServiceManager.h"
#import "ChatViewController.h"

@interface NewOfferViewController () {
    
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UILabel *lblNumber;
    __weak IBOutlet UILabel *lblPice;
    __weak IBOutlet UILabel *lblTotal;
    __weak IBOutlet ZSTextField *txtNumber;
    __weak IBOutlet ZSTextField *txtPrice;
    __weak IBOutlet ZSTextField *txtTotal;
    
    NSNumberFormatter *currencyFormatter;
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
    
    lblTitle.font = [DingoUISettings lightFontWithSize:16];
    lblNumber.font = lblPice.font = lblTotal.font = txtTotal.font = txtPrice.font = txtNumber.font = [DingoUISettings lightFontWithSize:14];
    
    txtNumber.keyboardType = UIKeyboardTypeNumberPad;
    txtPrice.keyboardType = UIKeyboardTypeDecimalPad;
    
    [txtNumber showToolbarWithDone];
    [txtPrice showToolbarWithDone];
    
    currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.currencySymbol = @"£";

    [self calculateTotal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirm:(id)sender {
    
    int numberOfTickets = [txtNumber.text intValue];
    double price = 0;
    if ([txtPrice.text hasPrefix:@"£"]) {
        price = [[txtPrice.text substringFromIndex:1] doubleValue];
    } else {
        price = [txtPrice.text intValue];
    }
    
    
    NSDictionary *params = @{@"ticket_id":self.ticket.ticket_id,
                             @"receiver_id": self.ticket.user_id,
                             @"num_tickets" :@(numberOfTickets),
                             @"price":@(price)
                             };
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    [WebServiceManager sendOffer:params completion:^(id response, NSError *error) {
        [loadingView hide];
        
        if (!error) {
            if (response[@"id"]) {
                [AppManager showAlert:@"Offer Sent!"];

                ChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                vc.ticket = self.ticket;
                
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } else {
            [AppManager showAlert:[error localizedDescription]];
        }
        
    }];

}

#pragma mark UITextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length  == 0 && textField == txtPrice)
    {
        textField.text = @"£";
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == txtPrice) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // Make sure that the currency symbol is always at the beginning of the string:
        if (![newText hasPrefix:@"£"])
        {
            return NO;
        }
    }
    
    // Default:
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    
    if (textField == txtPrice) {
        txtPrice.text = [txtPrice.text substringFromIndex:1];
        txtPrice.text = [currencyFormatter stringFromNumber:@( [txtPrice.text doubleValue])];
    }
    
    if (textField == txtNumber) {
        int number = [txtNumber.text intValue];
        if (self.ticket.number_of_tickets.intValue < number) {
            [AppManager showAlert:[NSString stringWithFormat:@"You can offer only %d tickets", self.ticket.number_of_tickets.intValue]];
            
            txtNumber.text = [self.ticket.number_of_tickets stringValue];
            
            return;
        } else if (number <= 0) {
            [AppManager showAlert:@"Enter valid number of tickets"];
            return;
        }
    }

    

    
    [self calculateTotal];
}

- (void)calculateTotal {
    int numberOfTickets = [txtNumber.text intValue];
    double price = 0;
    if ([txtPrice.text hasPrefix:@"£"]) {
        price = [[txtPrice.text substringFromIndex:1] doubleValue];
    } else {
        price = [txtPrice.text intValue];
    }
    
    double total = price * numberOfTickets;
    
    txtTotal.text = [currencyFormatter stringFromNumber:@( total)];
}

@end
