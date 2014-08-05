//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "ListTicketsViewController.h"

#import "DingoUISettings.h"
#import "CategorySelectionCell.h"
#import "DataManager.h"
#import "TicketPhotoCell.h"
#import "UploadPhotosViewController.h"
#import "PhotosPreviewCell.h"
#import "PreviewViewController.h"

#import "ZSTextField.h"
#import "ZSTextView.h"
#import "ZSDatePicker.h"
#import "ZSPickerView.h"
#import "AppManager.h"
#import "WebServiceManager.h"

static const CGFloat paypalCellShrinkedHeight = 36;
static const CGFloat paypalCellExpandedHeight = 170;

static const NSUInteger previewPhotosCellIndex = 10;
static const NSUInteger editPhotosCellIndex = 11;
static const NSUInteger uploadPhotosCellIndex = 12;
static const NSUInteger payPalCellIndex = 13;

@interface ListTicketsViewController () <UITextFieldDelegate, UITableViewDataSource, UploadPhotosVCDelegate, ZSTextFieldDelegate, ZSDatePickerDelegate , ZSPickerDelegate ,CategorySelectionDelegate> {
    
    Ticket* ticket;
    Event* event;
    
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UILabel *lblFromDate;
    __weak IBOutlet UILabel *lblToDate;
    __weak IBOutlet UILabel *lblPrice;
    __weak IBOutlet UILabel *lblFaceValue;
    __weak IBOutlet UILabel *lblTicketCount;
    __weak IBOutlet UILabel *lblTicketType;
    __weak IBOutlet UILabel *lblPayment;
    __weak IBOutlet UILabel *lbldelivery;
    __weak IBOutlet UILabel *lblDescription;
    __weak IBOutlet UILabel *lblCategory;
    
    ZSDatePicker *startDatePicker;
    ZSDatePicker *endDatePicker;
    
    ZSPickerView *paymentPicker;
    ZSPickerView *ticketTypePicker;
    ZSPickerView *deliveryPicker;

}

@property (nonatomic, weak) IBOutlet ZSTextField *nameField;
@property (weak, nonatomic) IBOutlet ZSTextField *locationField;
@property (nonatomic, weak) IBOutlet UITextField *startDateField;
@property (nonatomic, weak) IBOutlet UITextField *endDateField;
@property (nonatomic, weak) IBOutlet ZSTextField *priceField;
@property (nonatomic, weak) IBOutlet ZSTextField *faceValueField;
@property (nonatomic, weak) IBOutlet ZSTextField *ticketsCountField;
@property (weak, nonatomic) IBOutlet UITextField *ticketTypeField;
@property (nonatomic, weak) IBOutlet ZSTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *paymentField;
@property (nonatomic, weak) IBOutlet CategorySelectionCell *categoriesCell;
@property (weak, nonatomic) IBOutlet PhotosPreviewCell *photosPreviewCell;
@property (weak, nonatomic) IBOutlet UITextField *deliveryField;


@end

@implementation ListTicketsViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.categoriesCell.multipleSelection = NO;
    [self.categoriesCell useAllCategories];
    
    if ([AppManager sharedManager].draftTicket) {
        self.nameField.text = [AppManager sharedManager].draftTicket[@"name"];
        self.startDateField.text = [AppManager sharedManager].draftTicket[@"startDate"];
        self.endDateField.text = [AppManager sharedManager].draftTicket[@"endDate"];
        self.descriptionTextView.text = [AppManager sharedManager].draftTicket[@"description"];
        
        self.categoriesCell.selectedCategory = [AppManager sharedManager].draftTicket[@"categoryID"];
    }
    
    
    [self.nameField setPopoverSize:CGRectMake(0, self.nameField.frame.origin.y + self.nameField.frame.size.height, 320.0, 130.0)];
    [self.locationField setPopoverSize:CGRectMake(0, self.locationField.frame.origin.y + self.locationField.frame.size.height, 320.0, 130.0)];
    
    ticket = [[Ticket alloc] initWithEntity:[NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
    event = [[Event alloc] initWithEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
    
    [self.priceField showToolbarWithDone];
    [self.faceValueField showToolbarWithDone];
    [self.ticketsCountField showToolbarWithDone];
    
    startDatePicker = [[ZSDatePicker alloc] initWithDate:[NSDate date]];
    startDatePicker.delegate = self;
    self.startDateField.inputView = startDatePicker;
    
    endDatePicker = [[ZSDatePicker alloc] initWithDate:[NSDate date]];
    endDatePicker.delegate = self;
    self.endDateField.inputView = endDatePicker;
    
    NSDictionary *ticketInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TicketInfo.plist" ofType:nil]];
    
 
    ticketTypePicker = [[ZSPickerView alloc] initWithItems:@[ticketInfo[@"ticketTypes"]]];
    ticketTypePicker.delegate = self;
    self.ticketTypeField.inputView = ticketTypePicker;
    
    paymentPicker = [[ZSPickerView alloc] initWithItems:@[ticketInfo[@"paymentOptions"]]];
    paymentPicker.delegate = self;
    self.paymentField.inputView = paymentPicker;
    
    
    deliveryPicker = [[ZSPickerView alloc] initWithItems:@[ticketInfo[@"deliveryOptions"]]];
    deliveryPicker.delegate = self;
    self.deliveryField.inputView = deliveryPicker;
    
    self.descriptionTextView.placeholder = @"Add comments about event or ticket and delivery method e.g. pick up from my house or meet in central London";
    [self.descriptionTextView showToolbarWithDone];
    
    self.categoriesCell.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
}

- (void)saveDraft {
    [AppManager sharedManager].draftTicket = [[NSMutableDictionary alloc] init];
    
    [[AppManager sharedManager].draftTicket setValue:self.nameField.text forKey:@"name"];
    [[AppManager sharedManager].draftTicket setValue:self.startDateField.text forKey:@"startDate"];
    [[AppManager sharedManager].draftTicket setValue:self.endDateField.text forKey:@"endDate"];
    [[AppManager sharedManager].draftTicket setValue:self.priceField.text forKey:@"price"];
    [[AppManager sharedManager].draftTicket setValue:self.faceValueField.text forKey:@"faceValue"];
    [[AppManager sharedManager].draftTicket setValue:self.ticketsCountField.text forKey:@"ticketCount"];
    [[AppManager sharedManager].draftTicket setValue:self.descriptionTextView.text forKey:@"description"];
    [[AppManager sharedManager].draftTicket setValue:self.categoriesCell.selectedCategory forKey:@"categoryID"];
    [[AppManager sharedManager].draftTicket setValue:self.paymentField forKey:@"paymentOption"];
    [[AppManager sharedManager].draftTicket setValue:self.ticketTypeField forKey:@"ticketType"];
    [[AppManager sharedManager].draftTicket setValue:self.deliveryField forKey:@"deliveryOption"];
    
}

#pragma mark - UploadPhotosVCDelegate

- (void)displayPhotos:(NSArray *)array mainPhoto:(UIImage*)mainPhoto {
    self.photosPreviewCell.photos = [array mutableCopy];
    event.thumb = UIImagePNGRepresentation(mainPhoto);
    [self.tableView reloadData];
    if (array.count > 0 || mainPhoto) {
        self.changed = YES;
    }
    
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case payPalCellIndex:
            return [self.paymentField.text isEqual:@"PayPal"] ? paypalCellExpandedHeight : paypalCellShrinkedHeight;
            break;
        case editPhotosCellIndex: case previewPhotosCellIndex:
            if (!self.photosPreviewCell.photos.count) {
                return 0;
            }
            break;
            
        case uploadPhotosCellIndex:
            if (self.photosPreviewCell.photos.count) {
                return 0;
            }
            break;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.startDateField) {
        [self.endDateField becomeFirstResponder];
    } else if (textField == self.endDateField) {
        [self.priceField becomeFirstResponder];
    } else if (textField == self.priceField) {
        [self.faceValueField becomeFirstResponder];
    } else if (textField == self.faceValueField) {
        [self.ticketsCountField becomeFirstResponder];
    } else if (textField == self.ticketsCountField) {
        [self.descriptionTextView becomeFirstResponder];
    }
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.nameField) {
        if (self.nameField.text.length > 0) {
            event.name = self.nameField.text;
            lblName.textColor = [UIColor blackColor];
            self.changed = YES;
        }
        
    }
    
    if (textField == self.locationField) {
        if (self.locationField.text.length > 0) {
            lblLocation.textColor = [UIColor blackColor];
            self.changed = YES;
        }
        
    }
    
    if (textField == self.startDateField) {
        
        if (self.startDateField.text.length > 0) {
            NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
            formatter.dateFormat = @"hh:mm dd/MM/yyyy";
            event.date = [formatter dateFromString:self.startDateField.text];
            lblFromDate.textColor= [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.endDateField) {
        if (self.endDateField.text.length > 0) {
            NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
            formatter.dateFormat = @"hh:mm dd/MM/yyyy";
            event.endDate = [formatter dateFromString:self.endDateField.text];
            lblToDate.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.priceField) {
        if (self.priceField.text.length > 0) {
            ticket.price = @([self.priceField.text floatValue]);
            event.fromPrice = @([self.priceField.text floatValue]);
            lblPrice.textColor = [UIColor blackColor];
            self.changed = YES;
        }
        
    }

    if (textField == self.faceValueField) {
        if (self.faceValueField.text.length > 0) {
            ticket.face_value_per_ticket = @([self.faceValueField.text floatValue]);
            lblFaceValue.textColor = [UIColor blackColor];
        }
    }

    if (textField == self.ticketsCountField) {
        if (self.ticketsCountField.text.length > 0) {
            ticket.number_of_tickets = @([self.ticketsCountField.text intValue]);
            lblTicketCount.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.ticketTypeField) {
        if (self.ticketTypeField.text.length > 0) {
            lblTicketType.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.paymentField) {
        if (self.paymentField.text.length > 0) {
            lblPayment.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }

    if (textField == self.deliveryField) {
        if (self.deliveryField.text.length > 0) {
            lbldelivery.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }

    
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {

    BOOL requiredInfoFilled = YES;
    
    if ([identifier isEqualToString:@"PreviewSegue"]) {
        
        if (self.nameField.text.length == 0) {
            requiredInfoFilled = NO;
            lblName.textColor = [UIColor redColor];
        }
        
        if (self.locationField.text.length == 0) {
            requiredInfoFilled = NO;
            lblLocation.textColor = [UIColor redColor];
        }
        
        if (self.startDateField.text.length == 0) {
            requiredInfoFilled = NO;
            lblFromDate.textColor = [UIColor redColor];
        }
        
        if (self.endDateField.text.length == 0) {
            requiredInfoFilled = NO;
            lblToDate.textColor = [UIColor redColor];
        }
        
        if (self.priceField.text.length == 0) {
            requiredInfoFilled = NO;
            lblPrice.textColor = [UIColor redColor];
        }
        
        if (self.faceValueField.text.length == 0) {
            requiredInfoFilled = NO;
            lblFaceValue.textColor = [UIColor redColor];
        }
        
        if (self.ticketsCountField.text.length == 0) {
            requiredInfoFilled = NO;
            lblTicketCount.textColor = [UIColor redColor];
        }
        
        if (self.ticketTypeField.text.length == 0) {
            requiredInfoFilled = NO;
            lblTicketType.textColor = [UIColor redColor];
        }
        
        if (self.paymentField.text.length == 0) {
            requiredInfoFilled = NO;
            lblPayment.textColor = [UIColor redColor];
        }
        
        if (self.deliveryField.text.length == 0) {
            requiredInfoFilled = NO;
            lbldelivery.textColor = [UIColor redColor];
        }
        
        if (self.categoriesCell.selectedCategory.length == 0) {
            requiredInfoFilled = NO;
            lblCategory.textColor = [UIColor redColor];
        }
        
        if (!requiredInfoFilled) {
            [self.tableView setContentOffset:CGPointZero];
        }
    }

    return requiredInfoFilled;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditPhotosSegue"]) {
        UploadPhotosViewController *vc = (UploadPhotosViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.photos = self.photosPreviewCell.photos;
        vc.mainPhoto = [UIImage imageWithData:event.thumb];
    } else if ([segue.identifier isEqualToString:@"PreviewSegue"]) {
        
        ticket.payment_options = self.paymentField.text;
        ticket.delivery_options = self.deliveryField.text;
        ticket.ticket_type = self.ticketTypeField.text;
        ticket.ticket_desc = self.descriptionTextView.text;
        
        // selected category
        if (self.categoriesCell.selectedCategory) {
            event.category_id = self.categoriesCell.selectedCategory;
        }
        
        PreviewViewController *vc = (PreviewViewController *)segue.destinationViewController;
        vc.event = event;
        vc.ticket = ticket;
        vc.photos = self.photosPreviewCell.photos;
    }
}

#pragma mark ZSTextFieldDelegate

- (NSArray *)dataForPopoverInTextField:(ZSTextField *)textField {
    
    if (textField == self.nameField) {
        NSArray* events = [[DataManager shared] allEvents];
        NSMutableArray *dataForPopover = [NSMutableArray new];
        for (Event *tmpEvent in events) {
            [dataForPopover addObject:@{@"DisplayText": tmpEvent.name, @"CustomObject":tmpEvent}];
        }
        
        return dataForPopover;
    }
    
    if (textField == self.locationField) {
        self.locationField.applyFilter = NO;
        [WebServiceManager fetchLocations:textField.text completion:^(id response, NSError *error) {
           
            if ([response[@"status"] isEqualToString:@"OK"]) {
                NSArray * predictions = response[@"predictions"];          
                NSMutableArray *dataForPopover = [NSMutableArray new];
                for (NSDictionary * dict in predictions) {
                    [dataForPopover addObject:@{@"DisplayText": dict[@"description"], @"CustomObject":dict}];
                }
                [textField setAutocompleteData:dataForPopover];
            }
        }];
    }
    
    return nil;
}

- (void)textField:(ZSTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    if (textField == self.nameField) {
        
        if ([result[@"CustomObject"] isKindOfClass:[Event class]]) {
            event = result[@"CustomObject"];
            
            self.locationField.text = [DataManager eventLocation:event];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"hh:mm dd/MM/yyyy";
            
            self.startDateField.text =  [formatter stringFromDate:event.date];
            self.endDateField.text = [formatter stringFromDate:event.endDate];
        }
       
    }
    
    if (textField == self.locationField) {
        NSDictionary *placeInfo = result[@"CustomObject"];
        
        [WebServiceManager fetchLocationDetails:placeInfo[@"place_id"] completion:^(id response, NSError *error) {
            if ([response[@"status"] isEqualToString:@"OK"]) {
                NSArray *addressComponents = response[@"result"][@"address_components"];
                
                for (NSDictionary *component in addressComponents) {
                    
                    if ([component[@"types"] containsObject:@"route"]) {
                        event.address = component[@"long_name"];
                    }
                    
                    if ([component[@"types"] containsObject:@"locality"]) {
                        event.city = component[@"long_name"];
                    }
                    
                    if ([component[@"types"] containsObject:@"postal_code"]) {
                        event.postalCode = component[@"long_name"];
                    }
                }
            }
        }];
    }
}

- (BOOL)textFieldShouldSelect:(ZSTextField *)textField {
    if (textField == self.nameField || textField == self.locationField) {
        return YES;
    }
    
    return NO;
}

#pragma mark ZSDatePickerDelegate 

- (void)pickerDidPressDone:(ZSDatePicker*)picker withDate:(NSDate *)date {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm dd/MM/yyyy";
    
    if (picker == startDatePicker) {
        [self.startDateField resignFirstResponder];
        self.startDateField.text = [formatter stringFromDate:date];
    }

    if (picker == endDatePicker) {
        [self.endDateField resignFirstResponder];
        self.endDateField.text = [formatter stringFromDate:date];
    }
}

- (void)pickerDidPressCancel:(ZSDatePicker*)picker {
    
    if (picker == startDatePicker) {
        [self.startDateField resignFirstResponder];
    }
    
    if (picker == endDatePicker) {
        [self.endDateField resignFirstResponder];
    }
    
}

#pragma mark ZSPickerView methods

- (void)pickerViewDidPressDone:(ZSPickerView *)picker withInfo:(NSString*)selectionInfo {

    self.changed = YES;

    
    if (picker == ticketTypePicker) {
        
        self.ticketTypeField.text = selectionInfo;
        [self.ticketTypeField resignFirstResponder];
    }
    
    if (picker == paymentPicker) {
        self.paymentField.text = selectionInfo;
        [self.paymentField resignFirstResponder];
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
    if (picker == deliveryPicker) {
        
        self.deliveryField.text = selectionInfo;
        [self.deliveryField resignFirstResponder];
    }
}

- (void)pickerViewDidPressCancel:(ZSPickerView *)picker {
    if (picker == ticketTypePicker) {
        [self.ticketTypeField resignFirstResponder];
    }
    
    if (picker == paymentPicker) {
        [self.paymentField resignFirstResponder];
    }
    
    if (picker == deliveryPicker) {
        [self.deliveryField resignFirstResponder];
    }
}

- (void)didSelectedCategories:(NSArray*)categories {
    if (categories.count) {
        lblCategory.textColor = [UIColor darkGrayColor];
    }
}

@end
