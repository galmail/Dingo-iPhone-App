//
//  SelectCityViewController.m
//  Dingo
//
//  Created by logan on 6/6/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SelectCityViewController.h"

#import "DataManager.h"
#import "DingoUISettings.h"

@interface SelectCityViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UIPickerView *cityPicker;

@end

@implementation SelectCityViewController

#pragma mark - UIPickerViewDataSource

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component {
    
    NSString *title = [[DataManager shared] allCities][row];
    UIColor *color = [DingoUISettings foregroundColor];
    return [[NSAttributedString alloc] initWithString:title
                                           attributes:@{NSForegroundColorAttributeName:color}];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[DataManager shared] allCities].count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"%@ selected", [[DataManager shared] allCities][row]);
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
