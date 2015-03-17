//
//  LoginViewController.m
//  Dingo
//
//  Created by logan on 5/30/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIDevice+Additions.h"
#import "WebServiceManager.h"
#import "AppManager.h"
#import "SelectCityViewController.h"
#import "ZSLabel.h"
#import "ZSLoadingView.h"
#import "SlidingViewController.h"
#import "AboutViewController.h"
#import <TwitterKit/TwitterKit.h>


@interface LoginViewController () <UITextFieldDelegate, ZSLabelDelegate> {
    UIAlertView *termsAlertView;
}

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) UITextField *activeField;

@end

NSString *emailPreFix;

@implementation LoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //phil adding t and c comment
    ZSLabel *labelTandC = [[ZSLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 120, self.view.frame.size.height - 50, 240, 30)];
    labelTandC.delegate = self;
    [labelTandC setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=10 color='#FFFFFF'><center>By proceeding, you agree with Dingo's <a href='showTerms'>Terms & Conditions</a> and <a href='showTerms'>Privacy Policy</a>.</center></font>"]];
    [self.view addSubview:labelTandC];
    
    
    self.scrollView.contentSize = self.scrollView.frame.size;
    
    if ([AppManager sharedManager].token) {
        SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
        viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
    
    
    //twitter loging
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
            
            //signed in, now get email address
            if ([[Twitter sharedInstance] session]) {
                TWTRShareEmailViewController* shareEmailViewController = [[TWTRShareEmailViewController alloc]initWithCompletion:^(NSString* email2, NSError* error) {
                    NSLog(@"Email %@, Error: %@", email2, error);
                    
                    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
                    [loadingView show];
                    
                    NSString *email = @"temptwitterb@email.com";
                    if(email) {
                        // email received, now get user twitter details
                        //**********************************
                        NSString *twitterURL = [NSString stringWithFormat: @"https://api.twitter.com/1.1/users/show.json?screen_name=%@&user_id=%@", [session userName], [session userName]];
                        NSDictionary *params = @{@"id" : [session userName]};
                        NSError *clientError;
                        NSURLRequest *twitterRequest = [[[Twitter sharedInstance] APIClient]
                                                        URLRequestWithMethod:@"GET"
                                                        URL:twitterURL
                                                        parameters:params
                                                        error:&clientError];
                        if (twitterRequest) {
                            [[[Twitter sharedInstance] APIClient] sendTwitterRequest:twitterRequest
                                  completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                if (data) {
                                      //received user data, now register on backend and send to homepage
                                      NSError *jsonError;
                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                NSLog(@"requestReply: %@", json);
                                    
                                                //split name
                                                NSString* fullName = [NSString stringWithFormat:@"%@%@", json[@"name"], @" empty"];
                                                NSArray* firstLastStrings = [fullName componentsSeparatedByString:@" "];
                                                NSString* firstName = [firstLastStrings objectAtIndex:0];
                                                NSString* lastName = [firstLastStrings objectAtIndex:1];
                                    
                                                //edit picture URL to resize
                                                NSString *profileURL = json[@"profile_image_url"];
                                                profileURL = [profileURL stringByReplacingOccurrencesOfString:@"normal"withString:@"bigger"];
                                                                                  
                                                NSDictionary *params = @{ @"name" : firstName,
                                                                          @"surname": lastName,
                                                                          @"email" : email,
                                                                          @"password" : [NSString stringWithFormat:@"fb%@", [session userName]],
                                                                          @"fb_id" : [session userName],
                                                                          @"city": @"London",
                                                                          @"photo_url": profileURL,
                                                                          @"device_uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
                                                                          @"device_brand":@"Apple",
                                                                          @"device_model": [[UIDevice currentDevice] platformString],
                                                                          @"device_os":[[UIDevice currentDevice] systemVersion],
                                                                          @"device_location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ] };
                                                //now signin
                                                NSLog(@"Sign up: %@", params);
                                                //********************************
                                                [WebServiceManager signUp:params completion:^(id response, NSError *error) {
                                                    NSLog(@"signUp response %@", response);
                                                        if (error) {
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                            [loadingView hide];
                                                            [alert show];
                                                            
                                                        } else {
                                                        if (response) {
                                                            NSLog(@"WSM signUP response: %@", response);
                                                            //new user
                                                            if (response[@"authentication_token"]) {
                                                                [AppManager sharedManager].token = response[@"authentication_token"];
                                                    
                                                                [AppManager sharedManager].userInfo = [@{ @"id":response[@"id"],
                                                                                                          @"fb_id": response[@"fb_id"],
                                                                                                          @"email":response[@"email"],
                                                                                                          @"notification_email":response[@"email"],
                                                                                                          @"name": response[@"name"],
                                                                                                          @"surname": response[@"surname"],
                                                                                                          @"photo_url":response[@"photo_url"],
                                                                                                          @"city":response[@"city"],
                                                                                                          @"paypal_account": (![response[@"paypal_account"] isKindOfClass:[NSNull class]] && [response[@"paypal_account"] length]) ? response[@"paypal_account"] : @""} mutableCopy];
                                                    
                                                                [[NSUserDefaults standardUserDefaults] setObject:response[@"authentication_token"] forKey:@"auth_token"];
                                                                [[NSUserDefaults standardUserDefaults] setObject:response[@"email"] forKey:@"users_email"];
                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                
                                                                [loadingView hide];
                                                                //setting city as london and then send to homepage
                                                                NSString *txtCity = @"London";
                                                                [[AppManager sharedManager].userInfo setObject:txtCity forKey:@"city"];
                                                                [[NSUserDefaults standardUserDefaults] setObject:txtCity forKey:@"city"];
                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
                                                                viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
                                                                [self presentViewController:viewController animated:YES completion:nil];
                                                    
                                                            } else {
                                                            // old user, therefore login
                                                            NSDictionary *params = @{ @"email" : email,
                                                                                      @"password" : [NSString stringWithFormat:@"fb%@", [session userName]] };
                                                    
                                                                [WebServiceManager signIn:params completion:^(id response, NSError *error) {
                                                                NSLog(@"login response %@", response);
                                                                    if (error ) {
                                                                        [loadingView hide];
                                                                        [AppManager showAlert:@"Looks like you've already signed in via Facebook. Please continue via Facebook."];
                                                                    } else {
                                                                    if (response) {
                                                                        if ([response[@"success"] boolValue]) {
                                                                            [AppManager sharedManager].token = response[@"auth_token"];
                                                                            [AppManager sharedManager].userInfo = [
                                                                                                           @{@"id": response[@"id"],
                                                                                                             @"email": response[@"email"],
                                                                                                             @"notification_email": response[@"email"],
                                                                                                             @"name": response[@"name"],
                                                                                                             @"surname": response[@"surname"],
                                                                                                             @"allow_dingo_emails": response[@"allow_dingo_emails"],
                                                                                                             @"allow_push_notifications":  response[@"allow_push_notifications"],
                                                                                                             @"fb_id":response[@"fb_id"],
                                                                                                             @"photo_url":profileURL,
                                                                                                             @"city" : @"London",
                                                                                                             @"paypal_account":(![response[@"paypal_account"] isKindOfClass:[NSNull class]] && [response[@"paypal_account"] length]) ? response[@"paypal_account"] : @""} mutableCopy];
                                                                            if (response[@"auth_token"] ) {
                                                                        
                                                                                [[NSUserDefaults standardUserDefaults] setObject:response[@"auth_token"] forKey:@"auth_token"];
                                                                                [[NSUserDefaults standardUserDefaults] setObject:response[@"email"] forKey:@"users_email"];
                                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                            }
                                                                    
                                                                            //not sure why we're getting events and caterogies here?
                                                                            //[[DataManager shared] allCategoriesWithCompletion:^(BOOL finished) {}];
                                                                            //[[DataManager shared] allEventsWithCompletion:^(BOOL finished) { }];
                                                                            
                                                                            if ([AppManager sharedManager].deviceToken.length > 0) {
                                                                                // register device
                                                                                NSDictionary *deviceParams = @{ @"uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
                                                                                                        @"brand":@"Apple",
                                                                                                        @"model": [[UIDevice currentDevice] platformString],
                                                                                                        @"os":[[UIDevice currentDevice] systemVersion],
                                                                                                        @"app_version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                                                                                                        @"location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ]
                                                                                                        };
                                                                        
                                                                                [WebServiceManager registerDevice:deviceParams completion:^(id response, NSError *error) {
                                                                                    NSLog(@"WSM registerDevice response - %@", response);
                                                                                    NSLog(@"WSM registerDevice error - %@", error);
                                                                                }];
                                                                            }
                                                                            [loadingView hide];
                                                                            //setting city as london and then send to homepage
                                                                            NSString *txtCity = @"London";
                                                                            [[AppManager sharedManager].userInfo setObject:txtCity forKey:@"city"];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:txtCity forKey:@"city"];
                                                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                                                            SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
                                                                            viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
                                                                            [self presentViewController:viewController animated:YES completion:nil];
                                                                            
                                                                            
                                                                        } else {
                                                                            [loadingView hide];
                                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                            [alert show];
                                                                        }
                                                                    } else {
                                                                        [loadingView hide];
                                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                        [alert show];
                                                                    }
                                                                }
                                                            }];
                                                            }
                                                        } else {
                                                            [loadingView hide];
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign up, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                            [alert show];
                                                        }
                                                    }
                                                    }];
                                            //********************************
                                    } else {
                                    //failed to receive user data
                                    NSLog(@"Error: %@", connectionError);
                                    [loadingView hide];
                                    [AppManager showAlert:@"Oops, something went wrong. Please try again."];
                                    }
                            }];
                        }
                        else {
                        //failed to obtain twitter details to send request
                        NSLog(@"Error: %@", clientError);
                        [loadingView hide];
                        [AppManager showAlert:@"Oops, something went wrong. Please try again."];
                        }
                        //**********************************
                    } else {
                        // didn't allow email, show error...
                        [loadingView hide];
                        [AppManager showAlert:@"Oops, something went wrong. Please make sure you allow access to your email to login to Dingo!"];
                    }
                 }];
                
                [self presentViewController:shareEmailViewController animated:YES completion:nil];
            }
        } else {
            //twitter login failed
            NSLog(@"error: %@", [error localizedDescription]);
            [AppManager showAlert:@"Oops, something went wrong. Please try again."];
        }
    }];
    
    
        //set additional buttons and labels
        if(self.view.frame.size.height > 500) {
            //old iphone
            UIImageView *orIcon=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 15, 371, 30, 30)];
            [orIcon setImage:[UIImage imageNamed:@"or_icon.png"]];
            [self.view addSubview:orIcon];
            
            [logInButton setFrame:CGRectMake(self.view.frame.size.width/2 - 109, 417, 218, 35)];
            [self.view addSubview:logInButton];
            
            ZSLabel *label = [[ZSLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 150, 460, 300, 30)];
            label.delegate = self;
            [label setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=13 color='#FFFFFF'><center>We'll never post anything without your permission.</center></font>"]];
            [self.view addSubview:label];
            
            //old guest button
            //UIButton *btnGuest=[UIButton buttonWithType:UIButtonTypeCustom];
            //[btnGuest setFrame:CGRectMake(self.view.frame.size.width/2 - 110, 422, 220, 40)];
            //[btnGuest setImage:[UIImage imageNamed:@"btnGuestpw.png"]  forState:UIControlStateNormal];
            //[btnGuest addTarget:self action:@selector(btnGuestTap:) forControlEvents:UIControlEventTouchUpInside];
            //[self.view addSubview:btnGuest];
    
        } else {
            
            //later iphones
            [logInButton setFrame:CGRectMake(self.view.frame.size.width/2 - 109, 367, 218, 35)];
            [self.view addSubview:logInButton];
            
            ZSLabel *label = [[ZSLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 150, 405, 300, 30)];
            label.delegate = self;
            [label setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=13 color='#FFFFFF'><center>We'll never post anything without your permission.</center></font>"]];
            [self.view addSubview:label];
            
            //old guest button
            //UIButton *btnGuest=[UIButton buttonWithType:UIButtonTypeCustom];
            //[btnGuest setFrame:CGRectMake(self.view.frame.size.width/2 - 110, 370, 220, 40)];
            //[btnGuest setImage:[UIImage imageNamed:@"btnGuestpw.png"]  forState:UIControlStateNormal];
            //[btnGuest addTarget:self action:@selector(btnGuestTap:) forControlEvents:UIControlEventTouchUpInside];
            //[self.view addSubview:btnGuest];
        }
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}


- (IBAction)btnFBLoginTap:(id)sender {
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    [WebServiceManager signInWithFBAndUpdate:NO completion:^(id response, NSError *error) {
        [loadingView hide];
        
        if (response) {
            
            //setting city as london and then send to homepage
            NSString *txtCity = @"London";
            [[AppManager sharedManager].userInfo setObject:txtCity forKey:@"city"];
            [[NSUserDefaults standardUserDefaults] setObject:txtCity forKey:@"city"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
            viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            
            //sending to city select
            //    SelectCityViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCityViewController"];
            //    [self.navigationController pushViewController:viewController animated:YES];
        }else{
            [WebServiceManager handleError:error];
        }
    }];
    
    //old pop up
    
    //    termsAlertView = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Agree", nil];
    //    termsAlertView.tag = 1;
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 220, 90)];
    //    ZSLabel *label = [[ZSLabel alloc] initWithFrame:CGRectMake(10, 0, 240, 90)];
    //    label.delegate = self;
    //    [label setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=14 color='#000000'>By pressing \"Agree\", you agree to Dingo's terms and conditions and privacy policy.<br>They can be found <a href='showTerms'>Here</a></font>"]];
    //    [view addSubview:label];
    //    [termsAlertView setValue:view forKey:@"accessoryView"];
    //    [termsAlertView show];
    
}

- (IBAction)btnGuestTap:(id)sender {
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];

    //set device token for prefix of guest email
    NSString *emailDeviceToken = [NSString stringWithFormat:@"%@", [AppManager sharedManager].deviceToken];
    
    //if device token is empty, use "identifierForVendor" instead but trim first
    NSString *identifierForVendorString = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]];
    NSString *newidentifierForVendor = [identifierForVendorString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *newidentifierForVendor2 = [newidentifierForVendor stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //check
    if ([emailDeviceToken  isEqual: @"(null)"] || [emailDeviceToken  isEqual: @""] ) {
        emailPreFix = newidentifierForVendor2;
    } else {
        emailPreFix = emailDeviceToken;
    }
    
    //old
    //NSString *email = [NSString stringWithFormat:@"%@@guest.dingoapp.co.uk", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    
    //new
    NSString *email = [NSString stringWithFormat:@"%@@guest.dingoapp.co.uk", emailPreFix];
    NSLog(@"email: %@", email);

    NSString *pass = [NSString stringWithFormat:@"uid%@", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    
    NSDictionary *params = @{ @"name" : @"Guest",
                              @"surname": @"",
                              @"email" : email,
                              @"password" : pass,
                              @"device_uid": [AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"" ,
                              @"device_brand":@"Apple",
                              @"device_model": [[UIDevice currentDevice] platformString],
                              @"device_os":[[UIDevice currentDevice] systemVersion],
                              @"device_location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ],
                              @"city": @"London"
                              };
    
    [WebServiceManager signUp:params completion:^(id response, NSError *error) {
        NSLog(@"LVC signUp response %@", response);
        
        if (error) {
            
            [loadingView hide];
            
            [WebServiceManager handleError:error];
        } else {
            if (response) {
                [loadingView hide];
                if (response[@"authentication_token"]) {
                    [AppManager sharedManager].token = response[@"authentication_token"];
                    
                    [AppManager sharedManager].userInfo = [@{@"email":email, @"name": @"Guest"} mutableCopy];
                    
                    //setting city as london and then send to homepage
                    NSString *txtCity = @"London";
                    [[AppManager sharedManager].userInfo setObject:txtCity forKey:@"city"];
                    [[NSUserDefaults standardUserDefaults] setObject:txtCity forKey:@"city"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
                    viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
                    [self presentViewController:viewController animated:YES completion:nil];
                    
                    
                    //sending to city select
                    //    SelectCityViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCityViewController"];
                    //    [self.navigationController pushViewController:viewController animated:YES];
                    
                } else {
                    
                    // login
                    NSDictionary *params = @{ @"email" : email,
                                              @"password" : pass
                                              };
                    
                    [WebServiceManager signIn:params completion:^(id response, NSError *error) {
                        NSLog(@"LVC signIn response %@", response);
                        if (error ) {
                            [loadingView hide];
                            //old
                            //                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            //                                [alert show];
                            //ner
                            [WebServiceManager handleError:error];
                        } else {
                            [loadingView hide];
                            if (response) {
                                
                                if ([response[@"success"] boolValue]) {
                                    [AppManager sharedManager].token = response[@"auth_token"];
                                    
                                    [AppManager sharedManager].userInfo = [@{@"email":email, @"name": @"Guest"} mutableCopy];
                                    
                                    
                                    //setting city as london and then send to homepage
                                    NSString *txtCity = @"London";
                                    [[AppManager sharedManager].userInfo setObject:txtCity forKey:@"city"];
                                    [[NSUserDefaults standardUserDefaults] setObject:txtCity forKey:@"city"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
                                    viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
                                    [self presentViewController:viewController animated:YES completion:nil];
                                    
                                    
                                    
                                    //SelectCityViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCityViewController"];
                                    
                                    //[self.navigationController pushViewController:viewController animated:YES];
                                    
                                } else {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                }
                                
                            } else {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                            }
                        }
                    }];
                    
                }
                
            } else {
                [loadingView hide];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign up, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            [loadingView hide];
        }
        
        [loadingView hide];
    }];
    
    
    
    
    //old pop up
    
    //    termsAlertView = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Agree", nil];
    
    //    termsAlertView.tag = 2;
    
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 220, 90)];
    
    //    ZSLabel *label = [[ZSLabel alloc] initWithFrame:CGRectMake(15, 0, 240, 90)];
    //    label.delegate = self;
    //    [label setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=14 color='#000000'>By pressing \"Agree\", you agree to Dingo's terms and conditions and privacy policy.<br>They can be found <a href='showTerms'>Here</a></font>"]];
    //    [view addSubview:label];
    
    //    [termsAlertView setValue:view forKey:@"accessoryView"];
    
    //    [termsAlertView setValue:label forKey:@"accessoryView"];
    //    [termsAlertView show];
    
}




//old pop up for terms and conditions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1 && buttonIndex == 1) {
        
        ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
        [loadingView show];
        [WebServiceManager signInWithFBAndUpdate:NO completion:^(id response, NSError *error) {
            [loadingView hide];
            
            if (response) {
                SelectCityViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCityViewController"];
                [self.navigationController pushViewController:viewController animated:YES];
            }else{
                [WebServiceManager handleError:error];
            }
        }];
    }
    
    if (alertView.tag == 2 && buttonIndex == 1) {
        
        ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
        [loadingView show];
        
        NSString *email = [NSString stringWithFormat:@"%@@guest.dingoapp.co.uk", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
        NSLog(@"email: %@", email);
        NSString *pass = [NSString stringWithFormat:@"uid%@", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
        
        NSDictionary *params = @{ @"name" : @"Guest",
                                  @"surname": @"",
                                  @"email" : email,
                                  @"password" : pass,
                                  @"device_uid": [AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"" ,
                                  @"device_brand":@"Apple",
                                  @"device_model": [[UIDevice currentDevice] platformString],
                                  @"device_os":[[UIDevice currentDevice] systemVersion],
                                  @"device_location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ],
                                  @"city": @"London"
                                  };
        
        [WebServiceManager signUp:params completion:^(id response, NSError *error) {
            NSLog(@"LVC signUp response %@", response);
            
            if (error) {
                
                [loadingView hide];
                
                [WebServiceManager handleError:error];
            } else {
                if (response) {
                    [loadingView hide];
                    if (response[@"authentication_token"]) {
                        [AppManager sharedManager].token = response[@"authentication_token"];
                        
                        [AppManager sharedManager].userInfo = [@{@"email":email, @"name": @"Guest"} mutableCopy];
                        
                        SelectCityViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCityViewController"];
                        
                        [self.navigationController pushViewController:viewController animated:YES];
                        
                    } else {
                        
                        // login
                        NSDictionary *params = @{ @"email" : email,
                                                  @"password" : pass
                                                  };
                        
                        [WebServiceManager signIn:params completion:^(id response, NSError *error) {
                            NSLog(@"LVC signIn response %@", response);
                            if (error ) {
                                [loadingView hide];
                                //old
                                //                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                //                                [alert show];
                                //ner
                                [WebServiceManager handleError:error];
                            } else {
                                [loadingView hide];
                                if (response) {
                                    
                                    if ([response[@"success"] boolValue]) {
                                        [AppManager sharedManager].token = response[@"auth_token"];
                                        
                                        [AppManager sharedManager].userInfo = [@{@"email":email, @"name": @"Guest"} mutableCopy];
                                        
                                        SelectCityViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCityViewController"];
                                        
                                        [self.navigationController pushViewController:viewController animated:YES];
                                        
                                    } else {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                    }
                                    
                                } else {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                }
                            }
                        }];
                        
                    }
                    
                } else {
                    [loadingView hide];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign up, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
                [loadingView hide];
            }
            
            [loadingView hide];
        }];
        
        
    }
}

#pragma mark ZSLabelDelegate methods

- (void)ZSLabel:(id)ZSLabel didSelectLinkWithURL:(NSURL*)url {
    NSString * action = [url absoluteString];
    
    if ([action isEqualToString:@"showTerms"]) {
        
        [termsAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        AboutViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
}


@end

