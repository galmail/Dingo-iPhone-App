//
//  SettingsViewController.m
//  Dingo
//
//  Created by logan on 6/18/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

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

#pragma mark - UIActions

- (IBAction)facebookLoginSwitchValueChanged {

}

- (IBAction)pushNotificationSwitchValueChanged {
    
}

- (IBAction)dingoEmailsSwitchValueChanged {
    
}

@end