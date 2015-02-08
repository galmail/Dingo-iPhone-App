//
//  SearchTicketsViewController.m
//  Dingo
//
//  Created by logan on 6/18/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SearchTicketsViewController.h"
#import "SearchResultsViewController.h"
#import "WebServiceManager.h"
#import "CategorySelectionCell.h"
#import "DingoUISettings.h"
#import "DataManager.h"
#import "ZSLoadingView.h"
#import "ZSPickerView.h"
#import "ZSDatePicker.h"

@interface SearchTicketsViewController () <UITextFieldDelegate, UITableViewDataSource,CategorySelectionDelegate,ZSPickerDelegate,ZSDatePickerDelegate>{
    ZSPickerView *cityPicker;
    ZSDatePicker * datePicker;
    IBOutlet UILabel *lblKeyWords;
    IBOutlet UILabel *lblCategory;
    IBOutlet UILabel *lblCity;
    IBOutlet UILabel *lblDate;
    NSArray * selectedCategories;
}

@property (nonatomic, weak) IBOutlet CategorySelectionCell *categoriesCell;
@property (nonatomic, weak) IBOutlet UITextField *keywordsField;
@property (nonatomic, weak) IBOutlet UITextField *cityField;
@property (nonatomic, weak) IBOutlet UITextField *dateField;

@end

@implementation SearchTicketsViewController

#pragma mark - UITableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    lblKeyWords.font = [DingoUISettings fontWithSize:14];
    lblCategory.font = [DingoUISettings fontWithSize:16];
    lblCity.font = [DingoUISettings fontWithSize:14];
    lblDate.font = [DingoUISettings fontWithSize:14];
    
    
    cityPicker = [[ZSPickerView alloc] initWithItems:[[DataManager shared] allCities] allowMultiSelection:NO];
    cityPicker.delegate = self;
    
    
    
    datePicker = [[ZSDatePicker alloc] initWithDate:[NSDate date]];
    datePicker.delegate = self;
    [datePicker setPickerMode:UIDatePickerModeDate];

    self.dateField.inputView = datePicker;
    
    self.cityField.inputView = cityPicker;
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
    self.categoriesCell.multipleSelection = YES;
    self.categoriesCell.delegate = self;
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


//phil - dynamically change height of category cell based on no. of categories.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedCategories = [[[DataManager shared] allCategories] valueForKey:@"category_id"];
    NSUInteger numObjects = [selectedCategories count];
    switch (indexPath.row) {
        case 2: {
            if (numObjects > 2) {
                return 230;
            } else {
                return 145;
            }
            break;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}



#pragma mark - Category Selection Delegate
- (void)didSelectedCategories:(NSArray*)selectionArray{
    selectedCategories = selectionArray;
}


#pragma mark - UIActions

- (IBAction)search {
    // login
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.keywordsField.text.length>0) {
        [params setValue:self.keywordsField.text forKey:@"name"];
    }
    if (self.cityField.text.length>0) {
        [params setValue:self.cityField.text forKey:@"city"];
    }
    if (self.dateField.text.length>0) {
        [params setValue:self.dateField.text forKey:@"start_date"];
        [params setValue:self.dateField.text forKey:@"end_date"];
    }
    if (selectedCategories.count>0) {
        [params setValue:[selectedCategories componentsJoinedByString:@","] forKey:@"category_ids[]"];
    }
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Searching..."];
    [loadingView show];
    [WebServiceManager searchEvents:params completion:^(id response, NSError *error) {
        NSLog(@"STVC response %@", response);
        [loadingView hide];
        if (error ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            
            if (response) {
                
                if (response[@"events"]) {
                    
                    NSArray * events = response[@"events"];
                    NSMutableArray * searchedEvents = [NSMutableArray new];
                    for (NSDictionary * dict in events) {
                        
                        
                        NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[AppManager sharedManager].managedObjectContext];
                        Event *event = [[Event alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                        
                        event.address = [dict valueForKey:@"address"];
                        event.tickets = [NSNumber numberWithInt:[[dict valueForKey:@"available_tickets"] intValue]];
                        event.category_id = [dict valueForKey:@"category_id"];
                        event.city = [dict valueForKey:@"city"];
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ";
                        
                        NSDate *date = [formatter dateFromString:[dict valueForKey:@"date"]];
                        event.date = date;
                        event.event_desc = [dict valueForKey:@"description"];
                        date = [formatter dateFromString:[dict valueForKey:@"end_date"]];
                        event.endDate = date;
                        event.featured = [dict valueForKey:@"featured"];
                        event.for_sale = [dict valueForKey:@"for_sale"];
                        event.event_id = [dict valueForKey:@"id"];
                        event.fromPrice = [NSNumber numberWithInt:[[dict valueForKey:@"min_price"] intValue]];
                        event.name = [dict valueForKey:@"name"];
                        event.thumbUrl = [dict valueForKey:@"thumb"];
                        
                        [searchedEvents addObject:event];
                        
                    }
                    
                    SearchResultsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultsViewController"];
                    viewController.searchedEvents = searchedEvents;
                    [self.navigationController pushViewController:viewController animated:YES];
                    
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"No result for now, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"No result for now, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
    
}


#pragma mark ZSPickerDelegate methods

- (void)pickerViewDidPressDone:(ZSPickerView*)picker withInfo:(id)selectionInfo {
    
    self.cityField.text = selectionInfo;
    [self.cityField resignFirstResponder];
}

- (void)pickerViewDidPressCancel:(ZSPickerView*)picker {
    [self.cityField resignFirstResponder];
}

#pragma mark ZSDatePickerDelegate

- (void)pickerDidPressDone:(ZSDatePicker*)picker withDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    
    self.dateField.text = [formatter stringFromDate:date];
    [self.dateField resignFirstResponder];
    
}

- (void)pickerDidPressCancel:(ZSDatePicker*)picker {
    [self.dateField resignFirstResponder];
}
@end
