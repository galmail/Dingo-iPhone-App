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
#import "ZSTextField.h"



static const NSUInteger fbLoginAlert =	4847;
static const NSUInteger pushAlert =		2243;

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
@property (nonatomic, weak) IBOutlet ZSTextField *emailField;
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteNotificationsChangedNotification:) name:@"RemoteNotificationsChanged" object:nil];
    
    [self.emailField showToolbarWithDone];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -

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
    
    if ([[AppManager sharedManager].userInfo valueForKey:@"notification_email"]) {
        self.emailField.text =[[AppManager sharedManager].userInfo valueForKey:@"notification_email"];
    }
    
//    if ([[[AppManager sharedManager].userInfo valueForKey:@"fb_id"] length]) {
//        if ([[[AppManager sharedManager].userInfo valueForKey:@"fb_id"] isKindOfClass:[NSNull class]]) {
//            self.facebookLoginSwitch.on = NO;
//        } else {
//            NSString * fb_id = [[AppManager sharedManager].userInfo valueForKey:@"fb_id"];
//            if (fb_id.length == 0) {
//                self.facebookLoginSwitch.on =  NO;
//            }
//        }
//    } else {
//        self.facebookLoginSwitch.on = NO;
//    }
    
    if ([[AppManager sharedManager].userInfo valueForKey:@"allow_dingo_emails"]) {
        self.dingoEmailsSwitch.on =[[[AppManager sharedManager].userInfo valueForKey:@"allow_dingo_emails"] boolValue];
    }
	
	//old
//    if ([[AppManager sharedManager].userInfo valueForKey:@"allow_push_notifications"]) {
//        self.pushNotificationSwitch.on =[[[AppManager sharedManager].userInfo valueForKey:@"allow_push_notifications"] boolValue];
//    }
	//new
	[self updateNotificationsSwitch];

    //phil turning fields to not edit
    _surnameField.enabled = NO;
    _firstNameField.enabled = NO;
    _emailField.enabled = YES;
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
    
    //check for valid email address
    NSString *emailString = _emailField.text;
    NSString *nameString  = _firstNameField.text;
    NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
    
    if ( ![nameString isEqualToString:@"Guest"] && (([emailTest evaluateWithObject:emailString] != YES) || [emailString isEqualToString:@""])) {
        
        UIAlertView *loginalert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Please enter valid email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [loginalert show];
        
    } else {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    //if (self.firstNameField.text.length>0) {
    //    [params setValue:self.firstNameField.text forKey:@"name"];
    //}
    if (self.cityField.text.length>0) {
        [params setValue:self.cityField.text forKey:@"city"];
    }
    //if (self.surnameField.text.length>0) {
    //    [params setValue:self.surnameField.text forKey:@"surname"];
    //}
    if (self.emailField.text.length>0) {
        [params setValue:self.emailField.text forKey:@"notification_email"];
    }
    
    [params setObject:[NSNumber numberWithBool:self.pushNotificationSwitch.on] forKey:@"allow_push_notifications"];
    [params setObject:[NSNumber numberWithBool:self.dingoEmailsSwitch.on] forKey:@"allow_dingo_emails"];
//    if (!self.facebookLoginSwitch.on) {
//        [params setObject:@YES forKey:@"disconnect_fb_account"];
//    }
    
    //DLog(@"token %@", [AppManager sharedManager].token );
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Saving..."];
    [loadingView show];
    [WebServiceManager updateProfile:params completion:^(id response, NSError *error) {
        NSLog(@"SVC updateProfile(backButton) response %@", response);
        [loadingView hide];
        if (error ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            
            if (response) {
                
            }
            [[AppManager sharedManager].userInfo setValue:self.firstNameField.text forKey:@"name"];
            [[AppManager sharedManager].userInfo setValue:self.cityField.text forKey:@"city"];
            [[AppManager sharedManager].userInfo setValue:self.emailField.text forKey:@"notification_email"];
//            if (!self.facebookLoginSwitch.on) {
//                [[AppManager sharedManager].userInfo setObject:@"" forKey:@"fb_id"];
//            }
            
            [[AppManager sharedManager].userInfo setObject:[NSNumber numberWithBool:self.pushNotificationSwitch.on] forKey:@"allow_push_notifications"];
            [[AppManager sharedManager].userInfo setObject:[NSNumber numberWithBool:self.dingoEmailsSwitch.on] forKey:@"allow_dingo_emails"];
            
//            if (!self.facebookLoginSwitch.on) {
//                
//            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];

    }
    
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
    if (self.emailField.text.length>0) {
        [params setValue:self.emailField.text forKey:@"notification_email"];
    }
    
    [params setObject:[NSNumber numberWithBool:self.pushNotificationSwitch.on] forKey:@"allow_push_notifications"];
    [params setObject:[NSNumber numberWithBool:self.dingoEmailsSwitch.on] forKey:@"allow_dingo_emails"];
    if (!self.facebookLoginSwitch.on) {
        [params setObject:@"" forKey:@"fb_id"];
    }
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Saving..."];
    [loadingView show];
    [WebServiceManager updateProfile:params completion:^(id response, NSError *error) {
        NSLog(@"SVC updateProfile(saveButton) response %@", response);
        [loadingView hide];
        if (error ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            
            if (response) {
                
            }
            [[AppManager sharedManager].userInfo setValue:self.firstNameField.text forKey:@"name"];
            [[AppManager sharedManager].userInfo setValue:self.cityField.text forKey:@"city"];
            [[AppManager sharedManager].userInfo setValue:self.emailField.text forKey:@"notification_email"];
            if (!self.facebookLoginSwitch.on) {
                [[AppManager sharedManager].userInfo setObject:@"" forKey:@"fb_id"];
            }
            
            [[AppManager sharedManager].userInfo setObject:[NSNumber numberWithBool:self.pushNotificationSwitch.on] forKey:@"allow_push_notifications"];
            [[AppManager sharedManager].userInfo setObject:[NSNumber numberWithBool:self.dingoEmailsSwitch.on] forKey:@"allow_dingo_emails"];
            
            if (!self.facebookLoginSwitch.on) {
                
            }
        }
    }];
}

#pragma mark - UIActions

- (IBAction)facebookLoginSwitchValueChanged {
    
    if (self.facebookLoginSwitch.on) {
        if (![[[AppManager sharedManager].userInfo valueForKey:@"fb_id"] length]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Please login to Facebook to join the Dingo community." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
			alert.tag = fbLoginAlert;
            [alert show];
           
        }
        
	} else {
		//shouldnt we do something when user turns this off?
	}
}

- (IBAction)pushNotificationSwitchValueChanged {
	if (self.pushNotificationSwitch.on) {
		if (![self pushNotificationEnabledInSettings]) {
			self.pushNotificationSwitch.on = NO;
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications disabled" message:@"Push notification need to be enabled in Settings." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
			if (canOpenSettings) {
				[alert addButtonWithTitle:@"Settings"];
			}
			alert.tag = pushAlert;
			[alert show];
		} else {
			[[AppManager sharedManager].userInfo setValue:@YES forKey:@"allow_push_notifications"];
			//keep in mind this would be a "better" (more standard) way to check for api availability
			//if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
			if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")){
				
				[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
				[[UIApplication sharedApplication] registerForRemoteNotifications];
			}else{
				[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
			}
		}
	} else {
		[[AppManager sharedManager].userInfo setValue:@NO forKey:@"allow_push_notifications"];
		[[UIApplication sharedApplication] unregisterForRemoteNotifications];
	}
	
}

- (IBAction)dingoEmailsSwitchValueChanged {
    
}


#pragma mark push notifications stuff

- (BOOL)pushNotificationEnabledInSettings {
	
	BOOL notificationsOn;
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
		//ios8 and up
		notificationsOn = ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] != UIUserNotificationTypeNone);
	} else {
		//ios7 and down
        //for some reason this doesn't always work. Therefore replace with just the pop up.
		//notificationsOn = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
        
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
            [AppManager showAlert: @"Please make sure push notifications are switched ON in your phone settings to receive messages!"];
        }
        notificationsOn = TRUE;
	}
	return notificationsOn;
}

- (void)updateNotificationsSwitch {
	
	
	BOOL notificationsOn = [self pushNotificationEnabledInSettings];
	self.pushNotificationSwitch.on = [[[AppManager sharedManager].userInfo valueForKey:@"allow_push_notifications"] boolValue] && notificationsOn;
}

- (void)remoteNotificationsChangedNotification:(NSNotification*)notification {
	[self updateNotificationsSwitch];
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
	switch (alertView.tag) {
		case fbLoginAlert:
			if (buttonIndex != alertView.cancelButtonIndex) {
				[self fbLogin];
			} else {
				self.facebookLoginSwitch.on = NO;
			}
			break;
		case pushAlert:
			if (buttonIndex != alertView.cancelButtonIndex) {
				BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
				if (canOpenSettings) {
					NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
					[[UIApplication sharedApplication] openURL:url];
				}
			}
			break;
	}
	
}

- (void)fbLogin {
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please Wait..."];
    [loadingView show];
    
    [WebServiceManager signInWithFBAndUpdate:YES completion:^(id response, NSError *error) {
        [loadingView hide];
        if (response) {
             [self reloadData];
        }
        
    }];

}

@end