//
//  SelectCityViewController.m
//  Dingo
//
//  Created by logan on 6/6/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SelectCityViewController.h"
#import "SlidingViewController.h"

#import "DataManager.h"
#import "DingoUISettings.h"

#import "AppManager.h"
#import "ZSPickerView.h"

@interface SelectCityViewController () <ZSPickerDelegate>{
    
    __weak IBOutlet UILabel *lblCity;
    __weak IBOutlet UITextField *txtCity;
    
    ZSPickerView *cityPicker;
}

@end

@implementation SelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lblCity.font = txtCity.font = [DingoUISettings fontWithSize:16];
    
    cityPicker = [[ZSPickerView alloc] initWithItems:[[DataManager shared] allCities] allowMultiSelection:NO];
    cityPicker.delegate = self;
    txtCity.inputView = cityPicker;
    
}

- (IBAction)done:(id)sender {
    if (txtCity.text.length > 0) {
        
        [[AppManager sharedManager].userInfo setObject:txtCity.text forKey:@"city"];
        
        SlidingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
        viewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [AppManager showAlert:@"Please select city"];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark ZSPickerDelegate methods

- (void)pickerViewDidPressDone:(ZSPickerView*)picker withInfo:(id)selectionInfo {
    
    txtCity.text = selectionInfo;
    [txtCity resignFirstResponder];
}

- (void)pickerViewDidPressCancel:(ZSPickerView*)picker {
    [txtCity resignFirstResponder];
}


@end
