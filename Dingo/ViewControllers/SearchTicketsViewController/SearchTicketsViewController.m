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

@interface SearchTicketsViewController () <UITextFieldDelegate, UITableViewDataSource,CategorySelectionDelegate>{
    
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
    lblCategory.font = [DingoUISettings fontWithSize:20];
    lblCity.font = [DingoUISettings fontWithSize:14];
    lblDate.font = [DingoUISettings fontWithSize:14];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
    self.categoriesCell.multipleSelection = YES;
 //   self.categoriesCell.delegate = self;
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
    }
    if (selectedCategories.count>0) {
        [params setValue:selectedCategories forKey:@"category_ids"];
    }
    
    
    [WebServiceManager searchEvents:params completion:^(id response, NSError *error) {
        NSLog(@"response %@", response);
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
                        event.tickets = [NSNumber numberWithInt:[[dict valueForKey:@"available_tickets"] integerValue]];
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
                        event.event_id = [dict valueForKey:@"id"];
                        event.fromPrice = [NSNumber numberWithInt:[[dict valueForKey:@"min_price"] integerValue]];
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

@end
