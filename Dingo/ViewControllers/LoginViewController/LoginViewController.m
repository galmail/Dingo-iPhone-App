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

#import "SlidingViewController.h"

@interface LoginViewController () <UITextFieldDelegate> {
    
    __weak IBOutlet UIView *loadingView;
}

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) UITextField *activeField;

@end

@implementation LoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    loadingView.hidden = YES;
    loadingView.layer.cornerRadius = 5;
    self.scrollView.contentSize = self.scrollView.frame.size;
    
    if ([AppManager sharedManager].token) {
        SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
        viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)btnFBLoginTap:(id)sender {
    
    loadingView.hidden = NO;
    [FBSession openActiveSessionWithReadPermissions:@[@"email", @"user_birthday", @"user_location"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      
                                      if (error) {
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                          [alert show];
                                          
                                          loadingView.hidden = YES;
                                      } else {
                                          if (state == FBSessionStateOpen) {
                                              
                                              FBRequest *request = [FBRequest requestForMe];
                                              [request.parameters setValue:@"id,name,email,picture,birthday,location" forKey:@"fields"];
                                              
                                              [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
                                                  if (user) {
                                                      
                                                      NSString *birtday = nil;
                                                      if(user.birthday.length > 0) {
                                                          // change date format from MM/DD/YYYY to DD/MM/YYYY
                                                          NSArray *dateArray = [user.birthday componentsSeparatedByString:@"/"];
                                                          dateArray = @[ dateArray[1], dateArray[0], dateArray[2]];
                                                          birtday = [dateArray componentsJoinedByString:@"/"];
                                                      }
                                                      
                                                      NSDictionary *params = @{ @"name" : user.name,
                                                                                @"email" : user[@"email"],
                                                                                @"password" : user.objectID,
                                                                                @"date_of_birth": birtday.length > 0 ? birtday : @"",
                                                                                @"city": user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"",
                                                                                @"photo_url":user[@"picture"][@"data"][@"url"],
                                                                                @"device_uid":[[UIDevice currentDevice] uniqueDeviceIdentifier],
                                                                                @"device_brand":@"Apple",
                                                                                @"device_model": [[UIDevice currentDevice] platformString],
                                                                                @"device_os":[[UIDevice currentDevice] systemVersion],
                                                                                @"device_location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ]
                                                                                };
                                                      
                                                      
                                                      [WebServiceManager signUp:params completion:^(id response, NSError *error) {
                                                          NSLog(@"response %@", response);
                                                          if (error) {
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                              [alert show];
                                                              
                                                              loadingView.hidden = YES;
                                                          } else {
                                                              if (response) {
                                                                  
                                                                  if (response[@"authentication_token"]) {
                                                                      [AppManager sharedManager].token = response[@"authentication_token"];
                                                                      
                                                                      [AppManager sharedManager].userInfo = @{@"email":user[@"email"], @"name": user.name};
                                                                      
                                                                      SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
                                                                      viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
                                                                      [self presentViewController:viewController animated:YES completion:nil];
                                                                  } else {
                                                                      
                                                                      // login
                                                                      NSDictionary *params = @{ @"email" : user[@"email"],
                                                                                                @"password" : user.objectID
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
                                                                                      
                                                                                      [AppManager sharedManager].userInfo = @{@"email":user[@"email"], @"name": user.name};
                                                                                      
                                                                                      SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
                                                                                      viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
                                                                                      [self presentViewController:viewController animated:YES completion:nil];
                                                                                      
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
                                                              
                                                              loadingView.hidden = YES;
                                                          }
                                                          
                                                          
                                                      }];
                                                  } else {
                                                      loadingView.hidden = YES;
                                                  }
                                                  
                                                  
                                              }];
                                          } else {
                                              loadingView.hidden = YES;
                                          }
                                      }
                                      
                                  }];
}




@end
