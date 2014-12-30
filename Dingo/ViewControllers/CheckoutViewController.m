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
#import "PayPalMobile.h"

#import "ChatViewController.h"
#import "ZSLoadingView.h"

@interface CheckoutViewController () <PayPalPaymentDelegate, UIPopoverControllerDelegate>{
    
    __weak IBOutlet UILabel *lblEvent;
    __weak IBOutlet UILabel *lblNumber;
    __weak IBOutlet UILabel *lblPrice;
    __weak IBOutlet UILabel *lblDingoFee;
    __weak IBOutlet UILabel *lblTotal;
    __weak IBOutlet UILabel *lblSeller;
    __weak IBOutlet UILabel *lblPaymentOption;
    __weak IBOutlet UILabel *lblWhyCharged;
    __weak IBOutlet UILabel *lblWhyChargedSub;
    
    
    __weak IBOutlet ZSTextField *txtName;
    __weak IBOutlet ZSTextField *txtNumber;
    __weak IBOutlet ZSTextField *txtPrice;
    __weak IBOutlet ZSTextField *txtFieldfee;
    __weak IBOutlet ZSTextField *txtTotal;
    __weak IBOutlet ZSTextField *txtSellerName;
    __weak IBOutlet ZSTextField *txtPayment;
    __weak IBOutlet RoundedImageView *imgSeller;
    __weak IBOutlet UIButton *btnBuy;

    
    NSNumberFormatter *currencyFormatter;
    
    UIWebView *webView;
    
    PayPalConfiguration *payPalConfig;
    
    NSString *payPalKey;
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

    lblEvent.font = lblNumber.font = lblPrice.font = lblDingoFee.font=txtFieldfee.font =lblWhyCharged.font=lblWhyChargedSub.font = lblSeller.font = lblPaymentOption.font = txtPayment.font  = txtName.font = txtPrice.font = txtNumber.font = txtSellerName.font = [DingoUISettings lightFontWithSize:14];
    
    lblTotal.font= txtTotal.font=[DingoUISettings boldFontWithSize:14];
    [lblWhyChargedSub setFont:[DingoUISettings lightFontWithSize:12]];
    [lblWhyChargedSub setText:@"Dingo charges a small commission to cover all PayPal fees and \n  our secure payment and dispute service."];
    txtNumber.keyboardType = UIKeyboardTypeNumberPad;
    txtNumber.enabled = NO;
    [txtNumber showToolbarWithDone];
    
    txtName.text = self.event.name;
    txtNumber.text = [self.ticket.number_of_tickets stringValue];
    txtPrice.text = [currencyFormatter stringFromNumber:self.ticket.price];
    
//    if ([self.ticket.payment_options rangeOfString:@"Cash"].location != NSNotFound) {
//        txtPayment.text= @"Cash in person";
//    }
    
   // if ([self.ticket.payment_options rangeOfString:@"PayPal"].location != NSNotFound) {
        txtPayment.text= @"PayPal or Credit Card";
   // }
    
    txtSellerName.text = self.ticket.user_name;
    imgSeller.image = [UIImage imageWithData:self.ticket.user_photo];
    
    [self calculateTotal];
    
    payPalConfig = [[PayPalConfiguration alloc] init];
    payPalConfig.acceptCreditCards = YES;
    payPalConfig.languageOrLocale = @"en";
    payPalConfig.merchantName = @"Dingo, Inc.";
    

    
}

- (void)viewWillAppear:(BOOL)animated {
//    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
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
    
//    if ([self.ticket.payment_options rangeOfString:@"Cash"].location != NSNotFound) {
//        ChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
//        vc.ticket = self.ticket;
//        
//        [self.navigationController pushViewController:vc animated:YES];
//        
//        return;
//    }
    
    payPalKey = nil;
    
    if ([self.event.test boolValue]) {
         [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
    } else {
//#ifdef kProductionMode
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
//#else 
//        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
//#endif
    }
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = (NSDecimalNumber*)[currencyFormatter numberFromString:txtTotal.text];
    payment.currencyCode = @"GBP";
    payment.shortDescription = @"Dingo Test Payment ";
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:payPalConfig                                                                                                                     delegate:self];
    
    [self presentViewController:paymentViewController animated:YES completion:nil];

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
    if (total>0)
        txtFieldfee.text=[currencyFormatter stringFromNumber:@( (total*10)/100)];
        total=total+(total*10)/100;
        
    txtTotal.text = [currencyFormatter stringFromNumber:@( total)];
}

#pragma mark UITableView methods


#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success! \n%@",  [completedPayment confirmation]);
    
    payPalKey = [completedPayment confirmation][@"response"][@"id"];
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        if (payPalKey.length > 0) {
            NSDictionary *params = @{ @"ticket_id" : self.ticket.ticket_id,
                                      @"num_tickets": txtNumber.text,
                                      @"amount" : [currencyFormatter numberFromString:txtTotal.text],
                                      @"delivery_options" : self.ticket.delivery_options,
                                      @"order_paid":@"1",
                                      @"paypal_key":payPalKey
                                      };
            
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            
            [WebServiceManager makeOrder:params completion:^(id response, NSError *error) {
                [loadingView hide];
                if (!error) {
                    
                    NSLog(@"make order - %@", response);
                    if (response) {
                        
                        if (response[@"id"]) {
                            
                            
                            ChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                            vc.receiverID=response[@"receiver_id"];
                            vc.ticket = self.ticket;
                            
                            [self.navigationController pushViewController:vc animated:YES];
                            
                            [WebServiceManager payPalSuccess:@{@"order_id":response[@"id"]} completion:^(id response, NSError *error) {
                                
                            }];
                            
                            
                        } else {
                            [AppManager showAlert:@"Unable to buy!"];
                        }
                        
                    }
                }else{
                     [WebServiceManager genericError];
                }
            }];
        }
        
    }];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
