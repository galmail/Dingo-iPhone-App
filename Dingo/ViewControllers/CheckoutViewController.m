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
//#import "PayPalMobile.h"

#import "PayPal.h"
#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalInvoiceItem.h"
#import "ChatViewController.h"

static NSString *kPayPalAppID = @"APP-80W284485P519543T";

@interface CheckoutViewController () <PayPalPaymentDelegate, UIPopoverControllerDelegate>{
    
    __weak IBOutlet UILabel *lblEvent;
    __weak IBOutlet UILabel *lblNumber;
    __weak IBOutlet UILabel *lblPrice;
    __weak IBOutlet UILabel *lblTotal;
    __weak IBOutlet UILabel *lblSeller;
    __weak IBOutlet UILabel *lblPaymentOption;
    
    __weak IBOutlet ZSTextField *txtName;
    __weak IBOutlet ZSTextField *txtNumber;
    __weak IBOutlet ZSTextField *txtPrice;
    __weak IBOutlet ZSTextField *txtTotal;
    __weak IBOutlet ZSTextField *txtSellerName;
    __weak IBOutlet ZSTextField *txtPayment;
    __weak IBOutlet RoundedImageView *imgSeller;
    __weak IBOutlet UIButton *btnBuy;

    
    NSNumberFormatter *currencyFormatter;
    
    UIWebView *webView;
    
//    PayPalConfiguration *payPalConfig;
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
    
    [PayPal initializeWithAppID:kPayPalAppID forEnvironment:ENV_SANDBOX];
    
    currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.currencySymbol = @"£";

    lblEvent.font = lblNumber.font = lblPrice.font = lblTotal.font = lblSeller.font = lblPaymentOption.font = txtPayment.font = txtTotal.font = txtName.font = txtPrice.font = txtNumber.font = txtSellerName.font = [DingoUISettings lightFontWithSize:14];
    
    txtNumber.keyboardType = UIKeyboardTypeNumberPad;
    [txtNumber showToolbarWithDone];
    
    txtName.text = self.event.name;
    txtNumber.text = [self.ticket.number_of_tickets stringValue];
    txtPrice.text = [currencyFormatter stringFromNumber:self.ticket.price];
    
    if ([self.ticket.payment_options rangeOfString:@"Cash"].location != NSNotFound) {
        txtPayment.text= @"Cash in person";
    }
    
    if ([self.ticket.payment_options rangeOfString:@"PayPal"].location != NSNotFound) {
        txtPayment.text= @"PayPal, Credit Card";
    }
    
    txtSellerName.text = self.ticket.user_name;
    imgSeller.image = [UIImage imageWithData:self.ticket.user_photo];
    
    [self calculateTotal];
    
//    payPalConfig = [[PayPalConfiguration alloc] init];
//    payPalConfig.acceptCreditCards = YES;
//    payPalConfig.languageOrLocale = @"en";
//    payPalConfig.merchantName = @"Dingo, Inc.";
//
    
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
    
    if ([self.ticket.payment_options rangeOfString:@"Cash"].location != NSNotFound) {
        ChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        vc.ticket = self.ticket;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    
    NSDictionary *params = @{ @"ticket_id" : self.ticket.ticket_id,
                              @"num_tickets": txtNumber.text,
                              @"amount" : [currencyFormatter numberFromString:txtTotal.text],
                              @"delivery_options" : self.ticket.delivery_options
                             };
    
    [WebServiceManager makeOrder:params completion:^(id response, NSError *error) {
        if (!error) {
            
            NSLog(@"make order - %@", response);
            if (response) {
                
                if ([response[@"success"] boolValue]) {
                    
//                    PayPalPayment *payment = [[PayPalPayment alloc] init];
//                    payment.amount = (NSDecimalNumber*)[currencyFormatter numberFromString:txtTotal.text];
//                    payment.currencyCode = @"GBP";
//                    payment.shortDescription = @"Dingo Test Payment ";
//
//                    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
//                                                                                                                configuration:payPalConfig                                                                                                                     delegate:self];
//                    
//                    [self presentViewController:paymentViewController animated:YES completion:nil];

                    NSNumber *total = [currencyFormatter numberFromString:txtTotal.text];
                    
                    NSNumber *sellerTotal = @([total floatValue]*0.9f);
                    
                    
                    PayPalAdvancedPayment *advancedPayment = [[PayPalAdvancedPayment alloc] init];

                    advancedPayment.paymentCurrency = @"GBP";
                    advancedPayment.merchantName = @"Dingo, Inc.";
                    advancedPayment.ipnUrl = @"http://dingoapp.herokuapp.com/api/v1/paypal/notification?order_id=#{current_order.id}";
                    
                    
                    PayPalReceiverPaymentDetails *receiver = [[PayPalReceiverPaymentDetails alloc] init];
                    receiver.isPrimary = YES;
                    receiver.recipient = @"dingo@dingoapp.co.uk";
                    receiver.subTotal = (NSDecimalNumber*)total;
//                    receiver.paymentType = TYPE_GOODS;

//                    receiver.invoiceData = [[PayPalInvoiceData alloc] init];
//                    receiver.invoiceData.totalShipping = 0;
//                    receiver.invoiceData.totalTax = 0;
//                    receiver.invoiceData.invoiceItems = [NSMutableArray array];
//                    
//                    PayPalInvoiceItem *item = [[PayPalInvoiceItem alloc] init];
//                    item.totalPrice = receiver.subTotal;
//                    item.name = self.event.name;
//                    
//                    [receiver.invoiceData.invoiceItems addObject:item];
                    
                    PayPalReceiverPaymentDetails *receiver1 = [[PayPalReceiverPaymentDetails alloc] init];
                    receiver1.isPrimary = NO;
                    receiver1.recipient = @"asatur.galstyan@gmail.com";
                    receiver1.subTotal = (NSDecimalNumber*)sellerTotal;
                    
                    
                    advancedPayment.receiverPaymentDetails = [NSMutableArray array];
                    [advancedPayment.receiverPaymentDetails addObjectsFromArray:@[receiver, receiver1]];
                    
                   	[PayPal getPayPalInst].feePayer = FEEPAYER_PRIMARYRECEIVER;
                    [PayPal getPayPalInst].delegate = self;
                    [PayPal getPayPalInst].shippingEnabled = @NO;
                    [[PayPal getPayPalInst] advancedCheckoutWithPayment:advancedPayment];

                    
                } else {
                    [AppManager showAlert:@"Unable to buy!"];
                }
                
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

#pragma mark UITableView methods


#pragma mark PayPalPaymentDelegate methods

- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {
    
}

- (void)paymentFailedWithCorrelationID:(NSString *)correlationID {
    
}

- (void)paymentCanceled {
    
}

- (void)paymentLibraryExit {
    
    ChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    vc.ticket = self.ticket;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
