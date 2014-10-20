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

    self.scrollView.contentSize = self.scrollView.frame.size;
    
    if ([AppManager sharedManager].token) {
        SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
        viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)btnFBLoginTap:(id)sender {
    
    termsAlertView = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Agree", nil];

    termsAlertView.tag = 1;
    
    ZSLabel *label = [[ZSLabel alloc] initWithFrame:CGRectMake(0, 0, 220, 90)];
    label.delegate = self;
    [label setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=14 color='#000000'>By pressing \"Agree\", you agree to Dingo's terms and conditions and privacy policy.<br>They can be found <a href='showTerms'>Here</a></font>"]];

    [termsAlertView setValue:label forKey:@"accessoryView"];
    [termsAlertView show];

}

- (IBAction)btnGuestTap:(id)sender {
    
    termsAlertView = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Agree", nil];
    
    termsAlertView.tag = 2;
    
    ZSLabel *label = [[ZSLabel alloc] initWithFrame:CGRectMake(0, 0, 220, 90)];
    label.delegate = self;
    [label setText:[NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=14 color='#000000'>By pressing \"Agree\", you agree to Dingo's terms and conditions and privacy policy.<br>They can be found <a href='showTerms'>Here</a></font>"]];
    
    [termsAlertView setValue:label forKey:@"accessoryView"];
    [termsAlertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1 && buttonIndex == 1) {
        
        ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
        [loadingView show];
        [WebServiceManager signInWithFBAndUpdate:NO completion:^(id response, NSError *error) {
            [loadingView hide];
            if (response) {
                
                SelectCityViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCityViewController"];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }];
    }
    
    if (alertView.tag == 2 && buttonIndex == 1) {
        
        ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
        [loadingView show];
        
        NSString *email = [NSString stringWithFormat:@"%@@guest.dingoapp.co.uk", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
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
            NSLog(@"response %@", response);
            
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                [loadingView hide];
            } else {
                if (response) {
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
                            NSLog(@"response %@", response);
                            if (error ) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                            } else {
                                
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
