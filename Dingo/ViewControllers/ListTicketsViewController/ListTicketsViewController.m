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
#import "AppManager.h"


static const CGFloat paypalCellShrinkedHeight = 72;
static const CGFloat paypalCellExpandedHeight = 130;

static const CGFloat dateCellExpandedHeight = 200;
static const CGFloat dateCellShrinkedHeight = 36;

static const NSUInteger startDateCellIndex = 5;
static const NSUInteger endDateCellIndex = 6;
static const NSUInteger previewPhotosCellIndex = 12;
static const NSUInteger editPhotosCellIndex = 13;
static const NSUInteger uploadPhotosCellIndex = 14;
static const NSUInteger payPalCellIndex = 15;

@interface ListTicketsViewController () <UITextFieldDelegate, UITableViewDataSource, UploadPhotosVCDelegate, ZSTextFieldDelegate> {
    BOOL showStartDatePicker;
    BOOL showEndDatePicker;
    
    Ticket* ticket;
    Event* event;
}

@property (nonatomic, weak) IBOutlet ZSTextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *addressField;
@property (nonatomic, weak) IBOutlet UITextField *cityField;
@property (nonatomic, weak) IBOutlet UITextField *postCodeField;
@property (nonatomic, weak) IBOutlet UITextField *startDateField;
@property (nonatomic, weak) IBOutlet UITextField *endDateField;
@property (nonatomic, weak) IBOutlet UITextField *priceField;
@property (nonatomic, weak) IBOutlet UITextField *faceValueField;
@property (nonatomic, weak) IBOutlet UITextField *ticketsCountField;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UISwitch *paypalSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *cashSwitch;
@property (nonatomic, weak) IBOutlet UITextView *ticketDeliveryTextView;
@property (nonatomic, weak) IBOutlet CategorySelectionCell *categoriesCell;
@property (weak, nonatomic) IBOutlet PhotosPreviewCell *photosPreviewCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *paypalCell;
@property (nonatomic, weak) IBOutlet UIDatePicker *startDatePicker;
@property (nonatomic, weak) IBOutlet UIDatePicker *endDatePicker;

@end

@implementation ListTicketsViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.categoriesCell.multipleSelection = NO;
    [self.categoriesCell useAllCategories];
    self.paypalSwitch.on = NO;
    self.changed = YES;
    
    showStartDatePicker = showEndDatePicker = NO;
    
    [self.nameField setPopoverSize:CGRectMake(0, self.nameField.frame.origin.y + self.nameField.frame.size.height, 320.0, 100.0)];
    
    ticket = [[Ticket alloc] initWithEntity:[NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
    event = [[Event alloc] initWithEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
}

#pragma mark - UploadPhotosVCDelegate

- (void)displayPhotos:(NSArray *)array mainPhoto:(UIImage*)mainPhoto {
    self.photosPreviewCell.photos = [array mutableCopy];
    event.thumb = UIImagePNGRepresentation(mainPhoto);
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case startDateCellIndex: {
            self.startDatePicker.hidden = !showStartDatePicker;
            
            return showStartDatePicker ? dateCellExpandedHeight : dateCellShrinkedHeight;
            break;
        }
        case endDateCellIndex: {
            self.endDatePicker.hidden = !showEndDatePicker;
            
            return showEndDatePicker ? dateCellExpandedHeight : dateCellShrinkedHeight;
            break;
        }
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.startDateField) {
        showStartDatePicker = !showStartDatePicker;
        [self.tableView reloadData];
        
        return NO;
    }
    
    if (textField == self.endDateField) {
        showEndDatePicker = !showEndDatePicker;
        [self.tableView reloadData];
        
        return NO;
    }
    
    return YES;
}

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
        event.name = self.nameField.text;
    }
    
    if (textField == self.addressField) {
        event.address = self.addressField.text;
    }
    
    if (textField == self.cityField) {
        event.city = self.cityField.text;
    }
    
    if (textField == self.postCodeField) {
        event.postalCode = self.postCodeField.text;
    }
    
    if (textField == self.startDateField) {
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm dd/MM/yyyy";
        event.date = [formatter dateFromString:self.startDateField.text];
    }
    
    if (textField == self.endDateField) {
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm dd/MM/yyyy";
        event.endDate = [formatter dateFromString:self.endDateField.text];
    }
    
    if (textField == self.priceField) {
        ticket.price = @([self.priceField.text floatValue]);
        event.fromPrice = @([self.priceField.text floatValue]);
    }

    if (textField == self.faceValueField) {
        ticket.face_value_per_ticket = @([self.faceValueField.text floatValue]);
    }

    if (textField == self.ticketsCountField) {
        ticket.number_of_tickets = @([self.ticketsCountField.text intValue]);
    }
    
}

#pragma mark - UIActions

- (IBAction)cashSwitchValueChanged {
    
}

- (IBAction)paypalSwitchValueChanged {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditPhotosSegue"]) {
        UploadPhotosViewController *vc = (UploadPhotosViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.photos = self.photosPreviewCell.photos;
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
        if (self.categoriesCell.favoriteCategory) {
            EventCategory *cat = [[DataManager shared] dataByCategoryName:self.categoriesCell.favoriteCategory];
            event.category_id = cat.category_id;
        }
        
        PreviewViewController *vc = (PreviewViewController *)segue.destinationViewController;
        vc.event = event;
        vc.ticket = ticket;
        vc.photos = self.photosPreviewCell.photos;
    }
}

#pragma mark UIDatePicker 

- (IBAction)dateChanged:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm dd/MM/yyyy";
    
    if (sender == self.startDatePicker) {
        self.startDateField.text = [formatter stringFromDate:self.startDatePicker.date];
    }
    
    if (sender == self.endDatePicker) {
        self.endDateField.text = [formatter stringFromDate:self.endDatePicker.date];
    }

}

#pragma mark ZSTextFieldDelegate 

- (NSArray *)dataForPopoverInTextField:(ZSTextField *)textField {
    
    NSArray* events = [[DataManager shared] allEvents];

    NSMutableArray *dataForPopover = [NSMutableArray new];
    for (Event *tmpEvent in events) {
        [dataForPopover addObject:@{@"DisplayText": tmpEvent.name, @"CustomObject":tmpEvent}];
    }
    
   return dataForPopover;
}

- (void)textField:(ZSTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    
}

- (BOOL)textFieldShouldSelect:(ZSTextField *)textField
{
    return YES;
}


@end
