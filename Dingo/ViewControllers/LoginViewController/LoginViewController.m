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

@interface LoginViewController () <UITextFieldDelegate, ZSLabelDelegate> {
    UIAlertView *termsAlertView;
}

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) UITextField *activeField;

@end

@implementation LoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //phil adding t and c comment
    ZSLabel *labelTandC = [[ZSLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 120, self.view.frame.size.height - 50, 240, 30)];
    labelTandC.delegate = self;
    [labelTandC setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=10 color='#FFFFFF'><center>By proceeding, you agree with Dingo's <a href='showTerms'>Terms & Conditions</a> and <a href='showTerms'>Privacy Policy</a>.</center></font>"]];
    [self.view addSubview:labelTandC];
    
    
    //add OR image and guest button if screen hieght > iphone 4s
    if(self.view.frame.size.height > 500) {
        UIImageView *orIcon=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 22, 382, 44, 44)];
        [orIcon setImage:[UIImage imageNamed:@"or_icon.png"]];
        [self.view addSubview:orIcon];
        
        UIButton *btnGuest=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnGuest setFrame:CGRectMake(self.view.frame.size.width/2 - 111, 446, 220, 40)];
        [btnGuest setImage:[UIImage imageNamed:@"btnGuestpw.png"]  forState:UIControlStateNormal];
        [btnGuest addTarget:self action:@selector(btnGuestTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnGuest];
        
    } else {
        UIButton *btnGuest=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnGuest setFrame:CGRectMake(self.view.frame.size.width/2 - 111, 370, 220, 40)];
        [btnGuest setImage:[UIImage imageNamed:@"btnGuestpw.png"]  forState:UIControlStateNormal];
        [btnGuest addTarget:self action:@selector(btnGuestTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnGuest];
    }
    
    
    self.scrollView.contentSize = self.scrollView.frame.size;
    
    if ([AppManager sharedManager].token) {
        SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
        viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
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

