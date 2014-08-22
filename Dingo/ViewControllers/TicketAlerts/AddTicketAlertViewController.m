//
//  AddTicketAlertViewController.m
//  Dingo
//
//  Created by Tigran Aslanyan on 21.08.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "AddTicketAlertViewController.h"
#import "DingoUISettings.h"
#import "DataManager.h"

@interface AddTicketAlertViewController (){
    
    IBOutlet UITextField *txtDescription;
    IBOutlet UILabel *lblHint;
    IBOutlet UIButton *btnDelete;
    IBOutlet UIButton *btnConfirm;
}

@end

@implementation AddTicketAlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblHint.font = [DingoUISettings fontWithSize:18];
    if (!self.alert) {
        btnDelete.hidden = YES;
    }else{
        txtDescription.text = self.alert.alert_description;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)btnConfirmTap:(id)sender {
    if (txtDescription.text.length == 0) {
        [AppManager showAlert:@"Please enter description."];
        return;
    }
    if (!self.alert) {
        [[DataManager shared] addOrUpdateAlert:@{@"alert_id": [DataManager generateGUID],@"alert_description":txtDescription.text}];
    }else{
        [[DataManager shared] addOrUpdateAlert:@{@"alert_id": self.alert.alert_id,@"alert_description":txtDescription.text}];
    }
    [[DataManager shared] save];
    [self back];
}

- (IBAction)btnDeleteTap:(id)sender {
    [[AppManager sharedManager].managedObjectContext deleteObject:self.alert];
    [[DataManager shared] save];
    [self back];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
