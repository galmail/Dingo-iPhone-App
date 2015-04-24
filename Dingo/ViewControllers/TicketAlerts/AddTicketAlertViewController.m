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
#import "WebServiceManager.h"
#import "ZSLoadingView.h"
#import "ZSTextField.h"

@interface AddTicketAlertViewController (){
    
    IBOutlet ZSTextField *txtDescription;
    IBOutlet UILabel *lblHint;
    IBOutlet UIButton *btnDelete;
    IBOutlet UIButton *btnConfirm;
}

@end

NSString *trimmedDescriptionWithOutDate;

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
    
    txtDescription.clearButtonMode = UITextFieldViewModeUnlessEditing;
    
    lblHint.font = [DingoUISettings fontWithSize:18];
    if (!self.alert) {
        btnDelete.hidden = YES;
        
        self.alert = [[Alert alloc] initWithEntity:[NSEntityDescription entityForName:@"Alerts" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
    }else{
        txtDescription.text = self.alert.alert_description;
    }
    
     [txtDescription setPopoverSize:CGRectMake(0, txtDescription.frame.origin.y + txtDescription.frame.size.height, 320.0, 130.0)];
    
    [txtDescription showToolbarWithDone];
    
    
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
	else {
        
        //trimming date off the event description
        NSString *descriptionWithDate = txtDescription.text;
        NSRange match = [descriptionWithDate rangeOfString:@"-"];
        if(match.location != NSNotFound)
        {
            NSString *descriptionWithOutDate = [descriptionWithDate substringWithRange: NSMakeRange (0, match.location)];
            trimmedDescriptionWithOutDate = [descriptionWithOutDate stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        }
        
        //now check to see if we have the event
        NSArray* events = [[DataManager shared] allEventsWithAndWithoutTickets];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", trimmedDescriptionWithOutDate];
        
        NSArray *filteredEvents = [events filteredArrayUsingPredicate:predicate];
        if (filteredEvents.count == 0) {
            
            NSString *content = [NSString stringWithFormat: @"Please add an alert for: %@", descriptionWithDate];
            
            NSDictionary *params = @{@"receiver_id" : @"32", @"content" : content, @"visible" : @"false"};
            [WebServiceManager sendMessage:params completion:^(id response, NSError *error) {}];
			
			[AppManager showAlert:@"Sorry, no event matches your description :(\n\nBut fear not, we got your request and we'll add it for you! Please bear with us :)"];
            return;
            
        }
    }
	
    NSDictionary *params = @{@"on":@YES,
                             @"description": trimmedDescriptionWithOutDate,
                             @"event_id":self.alert.event_id,
                             @"price":@99999
                             };
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait ..."];
    [loadingView show];
    [WebServiceManager createAlert:params completion:^(id response, NSError *error) {
        [loadingView hide];
        if (response) {
            [[DataManager shared] addOrUpdateAlert:response];
        }else{
            
            [WebServiceManager handleError:error];
        }
        
       
        [self back];
    }];
  
}

- (IBAction)btnDeleteTap:(id)sender {
    [[AppManager sharedManager].managedObjectContext deleteObject:self.alert];
    [self back];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark ZSTextFieldDelegate

- (NSArray *)dataForPopoverInTextField:(ZSTextField *)textField {
    
    if (textField == txtDescription) {
        NSArray* events = [[DataManager shared] allEventsWithAndWithoutTickets];
        NSMutableArray *dataForPopover = [NSMutableArray new];
        for (Event *tmpEvent in events) {
            //old
            //[dataForPopover addObject:@{@"DisplayText": tmpEvent.name, @"CustomObject":tmpEvent}];
            
            //new displayed with date
            NSDate *shortDate = tmpEvent.date;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"dd MMMM";
            NSString *shortDateString = [formatter stringFromDate:shortDate];
            
            [dataForPopover addObject:@{@"DisplayText": [NSString stringWithFormat: @"%@ - %@", tmpEvent.name, shortDateString], @"CustomObject":tmpEvent}];
        }
        
        return dataForPopover;
    }
    return nil;
}

- (void)textField:(ZSTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    if (textField == txtDescription) {
        
        if ([result[@"CustomObject"] isKindOfClass:[Event class]]) {
            Event *event = result[@"CustomObject"];
            self.alert.event_id = event.event_id;
            
        }
        
    }
}

- (BOOL)textFieldShouldSelect:(ZSTextField *)textField {
    if (textField == txtDescription) {
        return YES;
    }
    
    return NO;
}



@end
