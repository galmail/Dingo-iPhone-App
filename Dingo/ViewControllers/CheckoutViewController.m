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
#import "CardIO.h"
#import "ChatViewController.h"
#import "ZSLoadingView.h"
#import <Parse/Parse.h>

@interface CheckoutViewController () <PayPalPaymentDelegate, CardIOPaymentViewControllerDelegate, UIPopoverControllerDelegate>{
    
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
    
    NSString *SecretKey;
    
    NSString *checkoutTotalInPenceString;
    
    NSString * StripePublishableKey;
    
    int checkoutTotalInPenceInt;
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
    [lblWhyChargedSub setText:@"Dingo charges a small commission to cover all PayPal fees and \nour Dingo fraud guarantee."];
    txtNumber.keyboardType = UIKeyboardTypeNumberPad;
    txtNumber.enabled = NO;
    [txtNumber showToolbarWithDone];
    
    txtName.text = self.event.name;
    txtNumber.text = [self.ticket.number_of_tickets stringValue];
    txtPrice.text = [currencyFormatter stringFromNumber:self.ticket.price];
    
    txtPayment.text= @"PayPal";
    
    txtSellerName.text = self.ticket.user_name;
    imgSeller.image = [UIImage imageWithData:self.ticket.user_photo];
    
    [self calculateTotal];
    
    payPalConfig = [[PayPalConfiguration alloc] init];
    payPalConfig.acceptCreditCards = NO;
    payPalConfig.languageOrLocale = @"en";
	payPalConfig.merchantName = PAYPAL_MERCHANT_NAME;
	payPalConfig.merchantPrivacyPolicyURL = PAYPAL_MERCHANT_PRIVACY_POLICY_URL;
    payPalConfig.merchantUserAgreementURL = PAYPAL_MERCHANT_USER_AGREEMENT_URL;
}


- (void)viewWillAppear:(BOOL)animated {
    [CardIOUtilities preload];
//    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buy:(id)sender {
	
	ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
	[loadingView show];
	
	NSDictionary *params = @{ @"id" : self.ticket.ticket_id};
	
	DLog(@"params: %@", params);
	[WebServiceManager tickets:params completion:^(id response, NSError *error) {
		NSLog(@"CVC tickets response %@", response);
		
		if (error) {
			[loadingView hide];
			[WebServiceManager handleError:error];
		} else if (response) {
			//AVAILABLE = TRUE
			NSArray *responseArray = response[@"tickets"];
			NSDictionary *responseDictionary = responseArray[0];
			BOOL ticketAvailable = [responseDictionary[@"available"] boolValue];
			
			if (ticketAvailable) {
				payPalKey = nil;
				
				if ([self.event.test boolValue]) {
					[PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
				} else {
					[PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
				}
				
				PayPalPayment *payment = [[PayPalPayment alloc] init];
				payment.amount = (NSDecimalNumber*)[currencyFormatter numberFromString:txtTotal.text];
				payment.currencyCode = @"GBP";
				payment.shortDescription = [NSString stringWithFormat:@"Dingo Payment (%@)", self.event.name];
				
				PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
																											configuration:payPalConfig                                                                                                                     delegate:self];
				[loadingView hide];
				[self presentViewController:paymentViewController animated:YES completion:nil];
			} else {
				//no tickets available
				[loadingView hide];
				[AppManager showAlert:@"Too late - ticket(s) have already been purchased! :("];
			}
		} else {
			//odd error
			[loadingView hide];
			[WebServiceManager genericError];
		}
	}];
}


- (IBAction)buywWithCard:(id)sender {
    
    if (checkoutTotalInPenceInt < 50){
        [AppManager showAlert:@"Checkout total must be above 50p to pay by credit/debit card!"];
    } else {
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    
    NSDictionary *params = @{ @"id" : self.ticket.ticket_id};
    
    DLog(@"params: %@", params);
    [WebServiceManager tickets:params completion:^(id response, NSError *error) {
        NSLog(@"CVC tickets response %@", response);
        
        if (error) {
            [loadingView hide];
            [WebServiceManager handleError:error];
        } else if (response) {
            //AVAILABLE = TRUE
            NSArray *responseArray = response[@"tickets"];
            NSDictionary *responseDictionary = responseArray[0];
            BOOL ticketAvailable = [responseDictionary[@"available"] boolValue];
            
            if (ticketAvailable) {
                
                if ([self.event.test boolValue]) {
                    //set test keys for stripe
                    SecretKey = @"sk_test_oOtIVbTqQwYv4akcaF44jY4I";
                    StripePublishableKey =  @"pk_test_3z444VHmE8tZV8iwtQ0skD9I";
                } else {
                    //set production keys for stripe
                    SecretKey = @"sk_live_B9Hy26fXoyBjWFj010RWOCtO";
                    StripePublishableKey = @"pk_live_vRGO5VfAT0G4xhA5OcbcnS9s";
                }
                
                if (StripePublishableKey) {
                    [Stripe setDefaultPublishableKey:StripePublishableKey];
                }
                
                [loadingView hide];
                
                CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
                scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:scanViewController animated:YES completion:nil];
                
            } else {
                //no tickets available
                [loadingView hide];
                [AppManager showAlert:@"Too late - ticket(s) have already been purchased! :("];
            }
        } else {
            //odd error
            [loadingView hide];
            [WebServiceManager genericError];
        }
    }];
    }
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
    
    double totalInPence = total *100;
    checkoutTotalInPenceInt = (int)(round(totalInPence));
    checkoutTotalInPenceString = [NSString stringWithFormat:@"%d", checkoutTotalInPenceInt];
    
}


#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success! \n%@",  [completedPayment confirmation]);
    
    payPalKey = [completedPayment confirmation][@"response"][@"id"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        float originalPrice=[txtNumber.text intValue]*[self.ticket.price doubleValue];
		//not being used now, commented to avoid the warning
		//NSString *ori=[NSString stringWithFormat:@"£%.2f",originalPrice];
		
        if (payPalKey.length > 0) {
            NSDictionary *params = @{ @"ticket_id" : self.ticket.ticket_id,
                                      @"num_tickets": txtNumber.text,
									  //old, not sure what is going on here...
									  //@"amount" : [currencyFormatter numberFromString:ori],
									  //new
									  @"amount" : [NSNumber numberWithFloat:originalPrice],
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
							
                            [AppManager showAlert:@"Ticket(s) purchased! You have been redirected to a chat with the seller. Please arrage ticket delivery here."];
                            
							//refresh chat after 3 seconds
							[vc performSelector:@selector(reloadMessagesWithCompletion:) withObject:nil afterDelay:3];
                            
                            [WebServiceManager payPalSuccess:@{@"order_id":response[@"id"]} completion:^(id response, NSError *error) {}];
                            
                        } else {
                            [AppManager showAlert:@"Payment received but unable to complete ticket purchase. Please get in touch at info@dingoapp.co.uk."];
                        }
                    }
                }else{
                     [WebServiceManager handleError:error];
                }
            }];
        }
        
    }];
}


- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"Scan succeeded with info: %@", info);
    
    [self dismissViewControllerAnimated:YES completion:^{
    
    //set card details
    STPCard *card = [[STPCard alloc] init];
    card.number = info.cardNumber;
    card.expMonth = info.expiryMonth;
    card.expYear = info.expiryYear;
    card.cvc = info.cvv;
        
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    
    //create Stripe token with card details
    [[STPAPIClient sharedClient] createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error) {
            //obtaining token failed
            [loadingView hide];
            DLog(@"failed to create a card token: %@", error);
            [AppManager showAlert:@"Unable to complete transaction. Please check card details and try again!"];
            
        } else {
            //successfully obtained token
            DLog(@"Token obtained: %@", token);
            
            //now use token to charge card
            [self createBackendChargeWithToken:token completion:^(STPBackendChargeResult status, NSError *error) {
                if (status == STPBackendChargeResultSuccess) {
                    
                        //successfully charged card, now complete order with Dingo backend
                        DLog(@"Card Charged!");
                        float originalPrice=[txtNumber.text intValue]*[self.ticket.price doubleValue];
                    
                        NSDictionary *params = @{ @"ticket_id" : self.ticket.ticket_id,
                                                  @"num_tickets": txtNumber.text,
                                                  @"amount" : [NSNumber numberWithFloat:originalPrice],
                                                  @"delivery_options" : self.ticket.delivery_options,
                                                  @"order_paid":@"1",
                                                  };
                    
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
                                        
                                        [AppManager showAlert:@"Ticket(s) purchased! You have been redirected to a chat with the seller. Please arrage ticket delivery here."];
                                        
                                        //refresh chat page after 4 seconds
                                        [vc performSelector:@selector(reloadMessagesWithCompletion:) withObject:nil afterDelay:4];
                                        
                                        [WebServiceManager payPalSuccess:@{@"order_id":response[@"id"]} completion:^(id response, NSError *error) {}];
                                        
                                    } else {
                                        [AppManager showAlert:@"Payment received but unable to complete ticket purchase. Please get in touch at info@dingoapp.co.uk."];
                                    }
                                }
                            }else{
                                [WebServiceManager handleError:error];
                            }
                        }];
                    
                } else {
                    //failed to charge card
                    [loadingView hide];
                    DLog(@"failed to charge card: %@", error);
                    [AppManager showAlert:@"Unable to complete transaction. Please check card details and try again!"];
                }
            }];
        }
    }];
    }];
}


- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    
    DLog(@"About to request charge using SecretKey: %@", SecretKey);
    DLog(@"About to request charge using StripePublishableKey: %@", StripePublishableKey);
    DLog(@"Checkout total is: %@", checkoutTotalInPenceString);
    
    NSDictionary *chargeParams = @{ @"token": token.tokenId, @"currency": @"gbp", @"amount": checkoutTotalInPenceString, @"SecretKey": SecretKey };
    
    // This passes the token off to Parse backend, which will then actually complete charging the card using Stripe account's secret key
    [PFCloud callFunctionInBackground:@"charge" withParameters:chargeParams block:^(id object, NSError *error) {
                if (error) {
                    completion(STPBackendChargeResultFailure, error);
                    return;
                }
                completion(STPBackendChargeResultSuccess, nil);
     }];
}


@end
