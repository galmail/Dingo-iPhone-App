//
//  SettingsViewController.m
//  Dingo
//
//  Created by logan on 6/18/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SettingsViewController.h"
#import "ZSLoadingView.h"
#import "WebServiceManager.h"
#import "ZSPickerView.h"
#import "DataManager.h"
#import "DingoUISettings.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIDevice+Additions.h"

@interface SettingsViewController ()<ZSPickerDelegate>{
    ZSPickerView *cityPicker;
    IBOutlet UILabel *lblCity;
    IBOutlet UILabel *lblFirstName;
    IBOutlet UILabel *lblSurname;
    IBOutlet UILabel *lblEmail;
    IBOutlet UILabel *lblFB;
    IBOutlet UILabel *lblPushNot;
    IBOutlet UILabel *lblDingoEmails;
}

@property (nonatomic, weak) IBOutlet UITextField *firstNameField;
@property (nonatomic, weak) IBOutlet UITextField *surnameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *cityField;
@property (nonatomic, weak) IBOutlet UISwitch *facebookLoginSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *pushNotificationSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *dingoEmailsSwitch;

@end

@implementation SettingsViewController

#pragma mark - UITableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
    
    
    lblCity.font = [DingoUISettings fontWithSize:15];
    lblFirstName.font = [DingoUISettings fontWithSize:15];
    lblSurname.font = [DingoUISettings fontWithSize:15];
    lblEmail.font = [DingoUISettings fontWithSize:15];
    lblFB.font = [DingoUISettings fontWithSize:15];
    lblPushNot.font = [DingoUISettings fontWithSize:15];
    lblDingoEmails.font = [DingoUISettings fontWithSize:15];
    
    cityPicker = [[ZSPickerView alloc] initWithItems:[[DataManager shared] allCities] allowMultiSelection:NO];
    cityPicker.delegate = self;
    self.cityField.inputView = cityPicker;
    
    [self reloadData];
}

- (void) reloadData {
    if ([[AppManager sharedManager].userInfo valueForKey:@"name"]) {
        self.firstNameField.text =[[AppManager sharedManager].userInfo valueForKey:@"name"];
    }
    if ([[AppManager sharedManager].userInfo valueForKey:@"surname"]) {
        self.surnameField.text =[[AppManager sharedManager].userInfo valueForKey:@"surname"];
    }
    
    if ([[AppManager sharedManager].userInfo valueForKey:@"city"]) {
        self.cityField.text =[[AppManager sharedManager].userInfo valueForKey:@"city"];
    }
    
    if ([[AppManager sharedManager].userInfo valueForKey:@"email"]) {
        self.emailField.text =[[AppManager sharedManager].userInfo valueForKey:@"email"];
    }
    
    if ([[AppManager sharedManager].userInfo valueForKey:@"fb_id"]) {
        if ([[[AppManager sharedManager].userInfo valueForKey:@"fb_id"] isKindOfClass:[NSNull class]]) {
            self.facebookLoginSwitch.on = NO;
        } else {
            NSString * fb_id = [[AppManager sharedManager].userInfo valueForKey:@"fb_id"];
            if (fb_id.length == 0) {
                self.facebookLoginSwitch.on = NO;
            }
        }
    } else {
        self.facebookLoginSwitch.on = NO;
    }
    if ([[AppManager sharedManager].userInfo valueForKey:@"allow_dingo_emails"]) {
        self.dingoEmailsSwitch.on =[[[AppManager sharedManager].userInfo valueForKey:@"allow_dingo_emails"] boolValue];
    }
    if ([[AppManager sharedManager].userInfo valueForKey:@"allow_push_notifications"]) {
        self.pushNotificationSwitch.on =[[[AppManager sharedManager].userInfo valueForKey:@"allow_push_notifications"] boolValue];
    }

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.firstNameField) {
        [self.surnameField becomeFirstResponder];
    } else if (textField == self.surnameField) {
        [self.emailField becomeFirstResponder];
    } else if (textField == self.emailField) {
        [self.cityField becomeFirstResponder];
    }
    
    return NO;
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.firstNameField.text.length>0) {
        [params setValue:self.firstNameField.text forKey:@"name"];
    }
    if (self.cityField.text.length>0) {
        [params setValue:self.cityField.text forKey:@"city"];
    }
    if (self.surnameField.text.length>0) {
        [params setValue:self.surnameField.text forKey:@"surname"];
    }
    
    [params setObject:[NSNumber numberWithBool:self.pushNotificationSwitch.on] forKey:@"allow_push_notifications"];
    [params setObject:[NSNumber numberWithBool:self.dingoEmailsSwitch.on] forKey:@"allow_dingo_emails"];
    if (!self.facebookLoginSwitch.on) {
        [params setObject:@"" forKey:@"fb_id"];
    }
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Saving..."];
    [loadingView show];
    [WebServiceManager updateProfile:params completion:^(id response, NSError *error) {
        NSLog(@"response %@", response);
        [loadingView hide];
        if (error ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            
            if (response) {
                
            }
            [[AppManager sharedManager].userInfo setValue:self.firstNameField.text forKey:@"name"];
            [[AppManager sharedManager].userInfo setValue:self.cityField.text forKey:@"city"];
            [[AppManager sharedManager].userInfo setValue:self.surnameField.text forKey:@"surname"];
            if (!self.facebookLoginSwitch.on) {
                [[AppManager sharedManager].userInfo setObject:@"" forKey:@"fb_id"];
            }
            
            [[AppManager sharedManager].userInfo setObject:[NSNumber numberWithBool:self.pushNotificationSwitch.on] forKey:@"allow_push_notifications"];
            [[AppManager sharedManager].userInfo setObject:[NSNumber numberWithBool:self.dingoEmailsSwitch.on] forKey:@"allow_dingo_emails"];
            
            if (!self.facebookLoginSwitch.on) {
                // [FBSession ]
            }
        }
    }];
}
#pragma mark - UIActions

- (IBAction)facebookLoginSwitchValueChanged {
    
    if (self.facebookLoginSwitch.on) {
        if (![[AppManager sharedManager].userInfo valueForKey:@"fb_id"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log in via Facebook?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
            [alert show];
           
        }
        
    }
}

- (IBAction)pushNotificationSwitchValueChanged {
    
}

- (IBAction)dingoEmailsSwitchValueChanged {
    
}

#pragma mark ZSPickerDelegate methods

- (void)pickerViewDidPressDone:(ZSPickerView*)picker withInfo:(id)selectionInfo {
    
    self.cityField.text = selectionInfo;
    [self.cityField resignFirstResponder];
}

- (void)pickerViewDidPressCancel:(ZSPickerView*)picker {
    [self.cityField resignFirstResponder];
}

#pragma mark FB Login

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
         [self fbLogin];
    } else {
        self.facebookLoginSwitch.on = NO;
    }
}

- (void)fbLogin {
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please Wait..."];
    [loadingView show];
    [FBSession openActiveSessionWithReadPermissions:@[@"email", @"user_birthday", @"user_location"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      
                                      if (error) {
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                          [alert show];
                                          
                                          [loadingView hide];
                                      } else {
                                          if (state == FBSessionStateOpen) {
                                              
                                              FBRequest *request = [FBRequest requestForMe];
                                              [request.parameters setValue:@"id,name,first_name,last_name,email,picture,birthday,location" forKey:@"fields"];
                                              
                                              [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
                                                  if (user) {
                                                      
                                                      NSString *birtday = nil;
                                                      if(user.birthday.length > 0) {
                                                          // change date format from MM/DD/YYYY to DD/MM/YYYY
                                                          NSArray *dateArray = [user.birthday componentsSeparatedByString:@"/"];
                                                          dateArray = @[ dateArray[1], dateArray[0], dateArray[2]];
                                                          birtday = [dateArray componentsJoinedByString:@"/"];
                                                      }
                                                      
                                                      NSDictionary *params = @{ @"name" : user.first_name,
                                                                                @"surname": user.last_name,
                                                                                @"email" : user[@"email"],
                                                                                @"password" : [NSString stringWithFormat:@"fb%@", user.objectID],
                                                                                @"fb_id" : user.objectID,
                                                                                @"date_of_birth": birtday.length > 0 ? birtday : @"",
                                                                                @"city": user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London",
                                                                                @"photo_url": [NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID],//user[@"picture"][@"data"][@"url"],
                                                                                @"device_uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
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
                                                              
                                                              [loadingView hide];
                                                          } else {
                                                              if (response) {
                                                                  
                                                                  if (response[@"authentication_token"]) {
                                                                      [AppManager sharedManager].token = response[@"authentication_token"];
                                                                      
                                                                      [AppManager sharedManager].userInfo = [@{ @"id":response[@"id"], @"email":user[@"email"], @"name": user.first_name, @"photo_url":[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID], @"city":user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London"} mutableCopy];
                                                                      
                                                                      [self reloadData];
                                                                      
                                                                  } else {
                                                                      
                                                                      // login
                                                                      NSDictionary *params = @{ @"email" : user[@"email"],
                                                                                                @"password" : [NSString stringWithFormat:@"fb%@", user.objectID]
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
                                                                                      
                                                                                      [AppManager sharedManager].userInfo = [@{@"id":response[@"id"], @"email":user[@"email"], @"name": user.first_name, @"surname": response[@"surname"], @"allow_dingo_emails": response[@"allow_dingo_emails"], @"allow_push_notifications":  response[@"allow_push_notifications"], @"fb_id": response[@"fb_id"], @"photo_url":[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID], @"city" : user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London"} mutableCopy];
                                                                                      
                                                                                      [self reloadData];
                                                                                      
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
                                                          
                                                          
                                                      }];
                                                  } else {
                                                      [loadingView hide];
                                                  }
                                                  
                                                  
                                              }];
                                          } else {
                                              [loadingView hide];
                                          }
                                      }
                                      
                                  }];
}

@end