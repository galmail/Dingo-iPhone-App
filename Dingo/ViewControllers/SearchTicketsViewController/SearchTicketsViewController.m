//
//  SearchTicketsViewController.m
//  Dingo
//
//  Created by logan on 6/18/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SearchTicketsViewController.h"

#import "CategorySelectionCell.h"

#import "DataManager.h"

@interface SearchTicketsViewController () <UITextFieldDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet CategorySelectionCell *categoriesCell;
@property (nonatomic, weak) IBOutlet UITextField *keywordsField;
@property (nonatomic, weak) IBOutlet UITextField *cityField;
@property (nonatomic, weak) IBOutlet UITextField *dateField;

@end

@implementation SearchTicketsViewController

#pragma mark - UITableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
    self.categoriesCell.multipleSelection = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.keywordsField) {
        [self.cityField becomeFirstResponder];
    } else if (textField == self.cityField) {
        [self.dateField becomeFirstResponder];
    }
    
    return NO;
}

#pragma mark - UIActions

- (IBAction)search {
    
}

@end
