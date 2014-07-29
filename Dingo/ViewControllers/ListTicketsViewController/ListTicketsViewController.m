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
#import "ZSDatePicker.h"
#import "AppManager.h"


static const CGFloat paypalCellShrinkedHeight = 72;
static const CGFloat paypalCellExpandedHeight = 130;

static const NSUInteger previewPhotosCellIndex = 12;
static const NSUInteger editPhotosCellIndex = 13;
static const NSUInteger uploadPhotosCellIndex = 14;
static const NSUInteger payPalCellIndex = 15;

@interface ListTicketsViewController () <UITextFieldDelegate, UITableViewDataSource, UploadPhotosVCDelegate, ZSTextFieldDelegate, ZSDatePickerDelegate > {
    
    Ticket* ticket;
    Event* event;
    
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblAddress;
    __weak IBOutlet UILabel *lblCity;
    __weak IBOutlet UILabel *lblPostCode;
    __weak IBOutlet UILabel *lblFromDate;
    __weak IBOutlet UILabel *lblToDate;
    __weak IBOutlet UILabel *lblPrice;
    __weak IBOutlet UILabel *lblFaceValue;
    __weak IBOutlet UILabel *lblTicketCount;
    __weak IBOutlet UILabel *lblDescription;
    
    ZSDatePicker *startDatePicker;
    ZSDatePicker *endDatePicker;
}

@property (nonatomic, weak) IBOutlet ZSTextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *addressField;
@property (nonatomic, weak) IBOutlet UITextField *cityField;
@property (nonatomic, weak) IBOutlet UITextField *postCodeField;
@property (nonatomic, weak) IBOutlet UITextField *startDateField;
@property (nonatomic, weak) IBOutlet UITextField *endDateField;
@property (nonatomic, weak) IBOutlet ZSTextField *priceField;
@property (nonatomic, weak) IBOutlet ZSTextField *faceValueField;
@property (nonatomic, weak) IBOutlet ZSTextField *ticketsCountField;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UISwitch *paypalSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *cashSwitch;
@property (nonatomic, weak) IBOutlet UITextView *ticketDeliveryTextView;
@property (nonatomic, weak) IBOutlet CategorySelectionCell *categoriesCell;
@property (weak, nonatomic) IBOutlet PhotosPreviewCell *photosPreviewCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *paypalCell;


@end

@implementation ListTicketsViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.categoriesCell.multipleSelection = NO;
    [self.categoriesCell useAllCategories];
    self.paypalSwitch.on = NO;
    
    if ([AppManager sharedManager].draftTicket) {
        self.nameField.text = [AppManager sharedManager].draftTicket[@"name"];
        self.addressField.text = [AppManager sharedManager].draftTicket[@"address"];
        self.cityField.text = [AppManager sharedManager].draftTicket[@"city"];
        self.postCodeField.text = [AppManager sharedManager].draftTicket[@"postCode"];
        self.startDateField.text = [AppManager sharedManager].draftTicket[@"startDate"];
        self.endDateField.text = [AppManager sharedManager].draftTicket[@"endDate"];
        self.descriptionTextView.text = [AppManager sharedManager].draftTicket[@"description"];
        
        self.categoriesCell.selectedCategory = [AppManager sharedManager].draftTicket[@"categoryID"];
    }
    
    
    [self.nameField setPopoverSize:CGRectMake(0, self.nameField.frame.origin.y + self.nameField.frame.size.height, 320.0, 100.0)];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
}

- (void)saveDraft {
    [AppManager sharedManager].draftTicket = [[NSMutableDictionary alloc] init];
    
    [[AppManager sharedManager].draftTicket setValue:self.nameField.text forKey:@"name"];
    [[AppManager sharedManager].draftTicket setValue:self.addressField.text forKey:@"address"];
    [[AppManager sharedManager].draftTicket setValue:self.cityField.text forKey:@"city"];
    [[AppManager sharedManager].draftTicket setValue:self.postCodeField.text forKey:@"postCode"];
    [[AppManager sharedManager].draftTicket setValue:self.startDateField.text forKey:@"startDate"];
    [[AppManager sharedManager].draftTicket setValue:self.endDateField.text forKey:@"endDate"];
    [[AppManager sharedManager].draftTicket setValue:self.priceField.text forKey:@"price"];
    [[AppManager sharedManager].draftTicket setValue:self.faceValueField.text forKey:@"faceValue"];
    [[AppManager sharedManager].draftTicket setValue:self.ticketsCountField.text forKey:@"ticketCount"];
    [[AppManager sharedManager].draftTicket setValue:self.descriptionTextView.text forKey:@"description"];
    [[AppManager sharedManager].draftTicket setValue:self.categoriesCell.selectedCategory forKey:@"categoryID"];
    
    
    // payment options
    NSString *payment_options = @"";
    if (self.paypalSwitch.on) {
        payment_options = @"paypal";
    }
    
    if (self.cashSwitch.on) {
        if (payment_options.length > 0) {
            payment_options = [payment_options stringByAppendingString:@",cash"];
        } else {
            payment_options = @"cash";
        }
    }
    
    [[AppManager sharedManager].draftTicket setValue:payment_options forKey:@"paymentOption"];
    
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
            return self.paypalSwitch.on ? paypalCellExpandedHeight : paypalCellShrinkedHeight;
            
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

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    if (textField == self.startDateField) {
//        showStartDatePicker = !showStartDatePicker;
//        [self.tableView reloadData];
//        
//        return NO;
//    }
//    
//    if (textField == self.endDateField) {
//        showEndDatePicker = !showEndDatePicker;
//        [self.tableView reloadData];
//        
//        return NO;
//    }
//    
//    return YES;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.nameField) {
        [self.addressField becomeFirstResponder];
    } else if (textField == self.addressField) {
        [self.cityField becomeFirstResponder];
    } else if (textField == self.cityField) {
        [self.postCodeField becomeFirstResponder];
    } else if (textField == self.postCodeField) {
        [self.startDateField becomeFirstResponder];
    } else if (textField == self.startDateField) {
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
    
    if (textField == self.addressField) {
        if (self.addressField.text.length > 0) {
            event.address = self.addressField.text;
            lblAddress.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.cityField) {
        if (self.cityField.text.length > 0) {
            event.city = self.cityField.text;
            lblCity.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.postCodeField) {
        if (self.postCodeField.text.length > 0) {
            event.postalCode = self.postCodeField.text;
            lblPostCode.textColor = [UIColor blackColor];
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
        if (self.endDateField.text.length > 0) {
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
    
}

#pragma mark - UIActions

- (IBAction)cashSwitchValueChanged {
    self.changed = YES;
}

- (IBAction)paypalSwitchValueChanged {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.changed = YES;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    BOOL requiredInfoFilled = YES;
    
    if ([identifier isEqualToString:@"PreviewSegue"]) {
        
        if (self.nameField.text.length == 0) {
            requiredInfoFilled = NO;
            lblName.textColor = [UIColor redColor];
        }
        
        if (self.addressField.text.length == 0) {
            requiredInfoFilled = NO;
            lblAddress.textColor = [UIColor redColor];
        }
        
        if (self.cityField.text.length == 0) {
            requiredInfoFilled = NO;
            lblCity.textColor = [UIColor redColor];
        }
        
        if (self.postCodeField.text.length == 0) {
            requiredInfoFilled = NO;
            lblPostCode.textColor = [UIColor redColor];
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
        
        // payment options
        NSString *payment_options = @"";
        if (self.paypalSwitch.on) {
            payment_options = @"paypal";
        }
        
        if (self.cashSwitch.on) {
            if (payment_options.length > 0) {
                payment_options = [payment_options stringByAppendingString:@",cash"];
            } else {
                payment_options = @"cash";
            }
        }
        
        ticket.payment_options = payment_options;
        
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
    
    return nil;
}

- (void)textField:(ZSTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    
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

@end
