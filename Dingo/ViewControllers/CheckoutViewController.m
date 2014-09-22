//
//  CheckoutViewController.m
//  Dingo
//
//  Created by Asatur Galstyan on 9/22/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "CheckoutViewController.h"
#import "ZSTextField.h"
#import "RoundedImageView.h"
#import "DingoUISettings.h"
#import "WebServiceManager.h"

@interface CheckoutViewController () {
    
    __weak IBOutlet UILabel *lblEvent;
    __weak IBOutlet UILabel *lblNumber;
    __weak IBOutlet UILabel *lblPrice;
    __weak IBOutlet UILabel *lblTotal;
    __weak IBOutlet UILabel *lblSeller;
    
    __weak IBOutlet ZSTextField *txtName;
    __weak IBOutlet ZSTextField *txtNumber;
    __weak IBOutlet ZSTextField *txtPrice;
    __weak IBOutlet ZSTextField *txtTotal;
    __weak IBOutlet ZSTextField *txtSellerName;
    __weak IBOutlet RoundedImageView *imgSeller;
    __weak IBOutlet UIButton *btnBuy;
    
    NSNumberFormatter *currencyFormatter;
    
}

@end

@implementation CheckoutViewController

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
    
    currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.currencySymbol = @"£";

    lblEvent.font = lblNumber.font = lblPrice.font = lblTotal.font = lblSeller.font = txtTotal.font = txtName.font = txtPrice.font = txtNumber.font = txtSellerName.font = [DingoUISettings lightFontWithSize:14];
    
    txtNumber.keyboardType = UIKeyboardTypeNumberPad;
    [txtNumber showToolbarWithDone];
    
    txtName.text = self.event.name;
    txtNumber.text = [self.ticket.number_of_tickets stringValue];
    txtPrice.text = [currencyFormatter stringFromNumber:self.ticket.price];
    
    txtSellerName.text = self.ticket.user_name;
    imgSeller.image = [UIImage imageWithData:self.ticket.user_photo];
    
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

- (IBAction)buy:(id)sender {
    
    NSDictionary *params = @{ @"ticket_id" : self.ticket.ticket_id,
                              @"num_tickets": txtNumber.text,
                              @"amount" : [currencyFormatter numberFromString:txtTotal.text],
                              @"delivery_options" : self.ticket.delivery_options
                             };
    
    [WebServiceManager makeOrder:params completion:^(id response, NSError *error) {
        if (!error) {
            
            NSLog(@"make order - %@", response);
            if (response) {
                
            }
        }
    }];
    
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    
    if (textField == txtNumber) {
        
        // validate ticket number
        int number = [txtNumber.text intValue];
        if (self.ticket.number_of_tickets.intValue < number) {
            [AppManager showAlert:[NSString stringWithFormat:@"You can buy only %d tickets", self.ticket.number_of_tickets.intValue]];
            
            txtNumber.text = [self.ticket.number_of_tickets stringValue];
            
            return;
        } else if (number <= 0) {
            [AppManager showAlert:@"Enter valid number of tickets"];
            return;
        }
        
        [self calculateTotal];
        
    }
    
    
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
