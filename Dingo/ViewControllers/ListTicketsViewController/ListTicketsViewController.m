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
#import <FacebookSDK/FacebookSDK.h>
#import "ZSLoadingView.h"
#import "UIDevice+Additions.h"

static const CGFloat paypalCellShrinkedHeight = 120;
static const CGFloat paypalCellExpandedHeight = 240;

static const NSUInteger previewPhotosCellIndex = 10;
static const NSUInteger editPhotosCellIndex = 11;
static const NSUInteger uploadPhotosCellIndex = 12;
static const NSUInteger payPalCellIndex = 13;
static const NSUInteger previewCellIndex = 16;
static const NSUInteger comfirmCellIndex = 17;

@interface ListTicketsViewController () <UITextFieldDelegate, UITableViewDataSource, UploadPhotosVCDelegate, ZSTextFieldDelegate, ZSDatePickerDelegate , ZSPickerDelegate ,CategorySelectionDelegate> {
    
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
    __weak IBOutlet UILabel *lbleTicket;
    __weak IBOutlet UILabel *lblPaper;
    __weak IBOutlet UILabel *lblCash;
    __weak IBOutlet UILabel *lblPaypal;
    __weak IBOutlet UILabel *lblInPerson;
    __weak IBOutlet UILabel *lblElectrical;
    __weak IBOutlet UILabel *lblPost;
    __weak IBOutlet UIButton *btnPreview;
    __weak IBOutlet UIButton *btnConfirm;
    
    ZSDatePicker *startDatePicker;
    ZSDatePicker *endDatePicker;
    
    ZSPickerView *paymentPicker;
    ZSPickerView *ticketTypePicker;
    ZSPickerView *deliveryPicker;

    __weak IBOutlet UISwitch *cashSwitch;
    __weak IBOutlet UISwitch *paypalSwitch;
    __weak IBOutlet UISwitch *inPersonSwitch;
    __weak IBOutlet UISwitch *electronicSwitch;
    __weak IBOutlet UISwitch *postSwitch;
    __weak IBOutlet UISwitch *eticketSwitch;
    __weak IBOutlet UISwitch *paperSwitch;
    
    BOOL isEditing;
    
    NSMutableArray *photos;
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
@property (nonatomic, weak) IBOutlet CategorySelectionCell *categoriesCell;
@property (weak, nonatomic) IBOutlet PhotosPreviewCell *photosPreviewCell;

@end

@implementation ListTicketsViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.categoriesCell.multipleSelection = NO;
    [self.categoriesCell useAllCategories];
    
    lblName.font = lblLocation.font = lblFromDate.font = lblToDate.font = lblPrice.font = lblFaceValue.font = lblTicketCount.font = lblTicketType.font = [DingoUISettings fontWithSize:14];
    lblPayment.font = lbldelivery.font = lbleTicket.font = lblPaper.font = lblCash.font = lblPaypal.font = lblInPerson.font = lblElectrical.font = lblPost.font = [DingoUISettings fontWithSize:14];
    lblCategory.font = [DingoUISettings fontWithSize:16];
    
    
    self.nameField.font = self.locationField.font = self.startDateField.font = self.endDateField.font = self.priceField.font = self.faceValueField.font = self.ticketsCountField.font = [DingoUISettings fontWithSize:14];
    
    [self.nameField setPopoverSize:CGRectMake(0, self.nameField.frame.origin.y + self.nameField.frame.size.height, 320.0, 130.0)];
    [self.locationField setPopoverSize:CGRectMake(0, self.locationField.frame.origin.y + self.locationField.frame.size.height, 320.0, 130.0)];
    
    
    if (self.ticket && self.event) {
        isEditing = YES;
        [self setTicket:self.ticket event:self.event];
    }
    
    [self.priceField showToolbarWithPrev:YES next:YES done:YES];
    [self.faceValueField showToolbarWithPrev:YES next:YES done:YES];
    [self.ticketsCountField showToolbarWithPrev:YES next:NO done:YES];
    
    startDatePicker = [[ZSDatePicker alloc] initWithDate:[NSDate date]];
    startDatePicker.delegate = self;
    [startDatePicker setPickerMode:UIDatePickerModeDateAndTime];
    self.startDateField.inputView = startDatePicker;
    
    endDatePicker = [[ZSDatePicker alloc] initWithDate:[NSDate date]];
    endDatePicker.delegate = self;
    [endDatePicker setPickerMode:UIDatePickerModeDateAndTime];
    self.endDateField.inputView = endDatePicker;
    
    NSDictionary *ticketInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TicketInfo.plist" ofType:nil]];
    
 
    ticketTypePicker = [[ZSPickerView alloc] initWithItems:ticketInfo[@"ticketTypes"] allowMultiSelection:NO];
    ticketTypePicker.delegate = self;
    self.ticketTypeField.inputView = ticketTypePicker;

    
    self.descriptionTextView.placeholder = @"Add comments about event or ticket and delivery method e.g. pick up from my house or meet in central London";
    [self.descriptionTextView showToolbarWithDone];
    
    self.categoriesCell.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;

    
    if (!self.ticket && !self.event) {
        self.changed = NO;
        
        self.ticket = [[Ticket alloc] initWithEntity:[NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
        
        self.event = [[Event alloc] initWithEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
        
        isEditing = NO;
        
    }
    
    if ([AppManager sharedManager].draftTicket) {
        
        self.nameField.text = [AppManager sharedManager].draftTicket[@"name"];
        self.locationField.text= [AppManager sharedManager].draftTicket[@"location"];
        self.startDateField.text = [AppManager sharedManager].draftTicket[@"startDate"];
        self.endDateField.text = [AppManager sharedManager].draftTicket[@"endDate"];
        self.descriptionTextView.text = [AppManager sharedManager].draftTicket[@"description"];
        self.priceField.text = [AppManager sharedManager].draftTicket[@"price"];
        self.faceValueField.text= [AppManager sharedManager].draftTicket[@"faceValue"];
        self.ticketsCountField.text = [AppManager sharedManager].draftTicket[@"ticketCount"];
        
        NSString *ticketType = [AppManager sharedManager].draftTicket[@"ticketType"];
        eticketSwitch.on = [ticketType rangeOfString:@"e-Ticket"].location != NSNotFound;
        paperSwitch.on = [ticketType rangeOfString:@"Paper"].location != NSNotFound;
        
        NSString *paymentOptions = [AppManager sharedManager].draftTicket[@"paymentOptions"];
        paypalSwitch.on = [paymentOptions rangeOfString:@"PayPal"].location != NSNotFound;
        cashSwitch.on = [paymentOptions rangeOfString:@"Cash in person"].location != NSNotFound;

        NSString *deliveryOptions = [AppManager sharedManager].draftTicket[@"deliveryOptions"];
        inPersonSwitch.on = [deliveryOptions rangeOfString:@"In Person"].location != NSNotFound;
        electronicSwitch.on = [deliveryOptions rangeOfString:@"Electronic"].location != NSNotFound;
        postSwitch.on =  [deliveryOptions rangeOfString:@"Post"].location != NSNotFound;
        
        photos = [AppManager sharedManager].draftTicket[@"photos"];
        if (!photos) {
            photos = [NSMutableArray new];
        }
            
        self.photosPreviewCell.photos = [photos mutableCopy];
        if (self.event.thumb) {
            [self.photosPreviewCell.photos insertObject:[UIImage imageWithData:self.event.thumb] atIndex:0];
        }
        
        self.categoriesCell.selectedCategory = [AppManager sharedManager].draftTicket[@"categoryID"];
        [self.categoriesCell refresh];
    } else if (!isEditing) {
        self.changed = NO;
        
        self.nameField.text = nil;
        self.locationField.text = nil;
        self.startDateField.text = nil;
        self.endDateField.text = nil;
        self.priceField.text = nil;
        self.faceValueField.text = nil;
        self.ticketsCountField.text = nil;
        self.descriptionTextView.text = nil;
        self.ticketTypeField.text = nil;
        
        paypalSwitch.on = NO;
        cashSwitch.on = NO;
        
        eticketSwitch.on = NO;
        paperSwitch.on = NO;
        
        inPersonSwitch.on = NO;
        electronicSwitch.on = NO;
        postSwitch.on = NO;
        
        self.event.thumb = nil;
        self.photosPreviewCell.photos = nil;
        
        photos = nil;
        
        self.categoriesCell.selectedCategory = nil;
        [self.categoriesCell refresh];
        
        [self.tableView reloadData];
        
    }
    
    
}

- (void)setTicket:(Ticket*)ticket event:(Event*)event {
   
    self.nameField.text = event.name;
    self.locationField.text = [DataManager eventLocation:event];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm dd/MM/yyyy";
    
    self.startDateField.text = [formatter stringFromDate:event.date];
    self.endDateField.text = [formatter stringFromDate:event.endDate];
    
    
    self.nameField.enabled = self.locationField.enabled = NO;
    self.startDateField.enabled = self.endDateField.enabled = NO;

    self.descriptionTextView.text = ticket.ticket_desc;
    self.priceField.text = [ticket.price stringValue];
    self.faceValueField.text= [ticket.face_value_per_ticket stringValue];
    self.ticketsCountField.text = [ticket.number_of_tickets stringValue];

    NSString *ticketType = ticket.ticket_type;
    eticketSwitch.on = [ticketType rangeOfString:@"e-Ticket"].location != NSNotFound;
    paperSwitch.on = [ticketType rangeOfString:@"Paper"].location != NSNotFound;

    
    NSString *paymentOptions = ticket.payment_options;
    paypalSwitch.on = [paymentOptions rangeOfString:@"PayPal"].location != NSNotFound;
    cashSwitch.on = [paymentOptions rangeOfString:@"Cash in person"].location != NSNotFound;
    
    NSString *deliveryOptions = ticket.delivery_options;
    inPersonSwitch.on = [deliveryOptions rangeOfString:@"In Person"].location != NSNotFound;
    electronicSwitch.on = [deliveryOptions rangeOfString:@"Electronic"].location != NSNotFound;
    postSwitch.on =  [deliveryOptions rangeOfString:@"Post"].location != NSNotFound;
    
    self.categoriesCell.selectedCategory = event.category_id;
    self.categoriesCell.readOnly = YES;
    [self.categoriesCell refresh];
    
    photos = [NSMutableArray new];
    if (ticket.photo1) {
        [photos addObject:[UIImage imageWithData:ticket.photo1]];
    }
    if (ticket.photo2) {
        [photos addObject:[UIImage imageWithData:ticket.photo2]];
    }
    if (ticket.photo3) {
        [photos addObject:[UIImage imageWithData:ticket.photo3]];
    }
    
    self.photosPreviewCell.photos = [photos mutableCopy];
    
    if (self.event.thumb) {
        [self.photosPreviewCell.photos insertObject:[UIImage imageWithData:self.event.thumb] atIndex:0];
    }
    
}

- (void)saveDraft {
    
    if (isEditing) {
        return;
    }
    
    [AppManager sharedManager].draftTicket = [[NSMutableDictionary alloc] init];
    
    NSString *paymentOption = @"";
    if (cashSwitch.on) {
        paymentOption = @"Cash in person";
    }
    
    if (paypalSwitch.on) {
        if (paymentOption.length > 0) {
            paymentOption = [paymentOption stringByAppendingFormat:@", %@", @"PayPal"];
        } else {
            paymentOption = @"PayPal";
        }
    }
    
    self.ticket.payment_options = paymentOption;
    
    NSString *deliveryOptions = @"";
    if (inPersonSwitch.on) {
        deliveryOptions = @"In Person";
    }
    
    if (electronicSwitch.on) {
        if (deliveryOptions.length > 0) {
            deliveryOptions = [deliveryOptions stringByAppendingFormat:@", %@", @"Electronic"];
        } else {
            deliveryOptions = @"Electronic";
        }
    }
    
    if (postSwitch.on) {
        if (deliveryOptions.length > 0) {
            deliveryOptions = [deliveryOptions stringByAppendingFormat:@", %@", @"Post"];
        } else {
            deliveryOptions = @"Post";
        }
    }
    
    self.ticket.delivery_options = deliveryOptions;
    
    NSString *ticketTypes = @"";
    if (eticketSwitch.on) {
        ticketTypes = @"e-Ticket";
    }
    
    if (paperSwitch.on) {
        if (ticketTypes.length > 0) {
            ticketTypes = [ticketTypes stringByAppendingFormat:@", %@", @"Paper"];
        } else {
            ticketTypes = @"Paper";
        }
    }
    
    self.ticket.ticket_type = ticketTypes;
    
    
    [[AppManager sharedManager].draftTicket setValue:self.nameField.text forKey:@"name"];
    [[AppManager sharedManager].draftTicket setValue:self.locationField.text forKey:@"location"];
    [[AppManager sharedManager].draftTicket setValue:self.startDateField.text forKey:@"startDate"];
    [[AppManager sharedManager].draftTicket setValue:self.endDateField.text forKey:@"endDate"];
    [[AppManager sharedManager].draftTicket setValue:self.priceField.text forKey:@"price"];
    [[AppManager sharedManager].draftTicket setValue:self.faceValueField.text forKey:@"faceValue"];
    [[AppManager sharedManager].draftTicket setValue:self.ticketsCountField.text forKey:@"ticketCount"];
    [[AppManager sharedManager].draftTicket setValue:self.descriptionTextView.text forKey:@"description"];
    [[AppManager sharedManager].draftTicket setValue:self.categoriesCell.selectedCategory forKey:@"categoryID"];
    [[AppManager sharedManager].draftTicket setValue:self.ticket.payment_options forKey:@"paymentOptions"];
    [[AppManager sharedManager].draftTicket setValue:self.ticket.ticket_type forKey:@"ticketType"];
    [[AppManager sharedManager].draftTicket setValue:self.ticket.delivery_options forKey:@"deliveryOptions"];
    if (photos.count) {
        [[AppManager sharedManager].draftTicket setObject:photos forKey:@"photos"];
    }
}

- (IBAction)confirm:(id)sender {
    
    NSDictionary *params = @{@"ticket_id":self.ticket.ticket_id,
                             @"price":[self.ticket.price stringValue],
                             @"ticket_type":self.ticket.ticket_type,
                             @"description":self.ticket.ticket_desc.length > 0 ? self.ticket.ticket_desc : @"",
                             @"delivery_options":self.ticket.delivery_options,
                             @"payment_options":self.ticket.payment_options,
                             @"number_of_tickets":[self.ticket.number_of_tickets stringValue],
                             @"face_value_per_ticket":[self.ticket.face_value_per_ticket stringValue]
                             };
    
    [WebServiceManager updateTicket:params photos:photos completion:^(id response, NSError *error) {
        NSLog(@"response %@", response);
    }];
}

#pragma mark - UploadPhotosVCDelegate

- (void)displayPhotos:(NSArray *)array mainPhoto:(UIImage*)mainPhoto {
    photos = [array mutableCopy];
    self.photosPreviewCell.photos = [array mutableCopy];
    if (mainPhoto) {
        
       
        //Have the image draw itself in the correct orientation if necessary
        if(!(mainPhoto.imageOrientation == UIImageOrientationUp ||
             mainPhoto.imageOrientation == UIImageOrientationUpMirrored))
        {
            CGSize imgsize = mainPhoto.size;
            UIGraphicsBeginImageContext(imgsize);
            [mainPhoto drawInRect:CGRectMake(0.0, 0.0, imgsize.width, imgsize.height)];
            mainPhoto = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        NSData *rotated = UIImageJPEGRepresentation(mainPhoto,0.2);
        
        
        [self.photosPreviewCell.photos insertObject:[UIImage imageWithData:rotated] atIndex:0];
        self.event.thumb = rotated;
    }
    
    [self.tableView reloadData];
    if (array.count > 0 || mainPhoto) {
        self.changed = YES;
    }
    
    [self saveDraft];
    
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case payPalCellIndex:
            return paypalSwitch.on ? paypalCellExpandedHeight : paypalCellShrinkedHeight;
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
        case previewCellIndex:
            btnPreview.hidden = isEditing;
            if (isEditing) {
                return 0;
            }
            break;
        case comfirmCellIndex:
            btnConfirm.hidden = !isEditing;
            if (!isEditing) {
                return 0;
            }
            break;
            
            
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.endDateField) {
        if ( self.startDateField.text.length > 0) {
            [endDatePicker setDate:self.event.date];
        }
    }
}

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
            
            if (self.event.event_id &&  ![self.event.name isEqual:self.nameField.text]) {
                self.event.event_id = nil;
                self.locationField.enabled = YES;
                self.startDateField.enabled = YES;
                self.endDateField.enabled = YES;

                self.categoriesCell.readOnly = NO;
                [self.categoriesCell refresh];
            }
            
            self.event.name = self.nameField.text;
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
            formatter.dateFormat = @"HH:mm dd/MM/yyyy";
            self.event.date = [formatter dateFromString:self.startDateField.text];
            lblFromDate.textColor= [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.endDateField) {
        if (self.endDateField.text.length > 0) {
            NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
            formatter.dateFormat = @"HH:mm dd/MM/yyyy";
            self.event.endDate = [formatter dateFromString:self.endDateField.text];
            lblToDate.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }
    
    if (textField == self.priceField) {
        if (self.priceField.text.length > 0) {
            self.ticket.price = @([self.priceField.text floatValue]);
            self.event.fromPrice = @([self.priceField.text floatValue]);
            lblPrice.textColor = [UIColor blackColor];
            self.changed = YES;
        }
        
    }

    if (textField == self.faceValueField) {
        if (self.faceValueField.text.length > 0) {
            self.ticket.face_value_per_ticket = @([self.faceValueField.text floatValue]);
            lblFaceValue.textColor = [UIColor blackColor];
        }
    }

    if (textField == self.ticketsCountField) {
        if (self.ticketsCountField.text.length > 0) {
            self.ticket.number_of_tickets = @([self.ticketsCountField.text intValue]);
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
  
}

#pragma mark - Navigation

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([[AppManager sharedManager].userInfo[@"name"] isEqualToString:@"Guest"] && [identifier isEqualToString:@"PreviewSegue"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Facebook login is required when selling tickets to promote a safe community. Don’t worry, we won’t share anything on your wall." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        [alert show];
        return NO;
    }
    

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

        if (!inPersonSwitch.on && !electronicSwitch.on && !postSwitch.on ) {
            requiredInfoFilled = NO;
            lbldelivery.textColor = [UIColor redColor];
        }
        
        if (self.categoriesCell.selectedCategory.length == 0) {
            requiredInfoFilled = NO;
            lblCategory.textColor = [UIColor redColor];
        }
        
        if (!paypalSwitch.on && !cashSwitch.on) {
            requiredInfoFilled = NO;
            lblPayment.textColor = [UIColor redColor];
        }
        
        if (!eticketSwitch.on && !paperSwitch.on) {
            requiredInfoFilled = NO;
            lblTicketType.textColor = [UIColor redColor];
        }
        
        if (!requiredInfoFilled) {
            [AppManager showAlert:@"Please complete compulsory fields."];
            [self.tableView setContentOffset:CGPointZero];
        }
    }

    return requiredInfoFilled;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self saveDraft];
    
    if ([segue.identifier isEqualToString:@"EditPhotosSegue"] || [segue.identifier isEqualToString:@"UploadPhotosSegue"]) {
        UploadPhotosViewController *vc = (UploadPhotosViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.mainPhoto = [UIImage imageWithData:self.event.thumb];
        vc.photos = photos;
    } else if ([segue.identifier isEqualToString:@"PreviewSegue"]) {
        
        NSString *paymentOption = @"";
        if (cashSwitch.on) {
            paymentOption = @"Cash in person";
        }
        
        if (paypalSwitch.on) {
            if (paymentOption.length > 0) {
                paymentOption = [paymentOption stringByAppendingFormat:@", %@", @"PayPal"];
            } else {
                paymentOption = @"PayPal";
            }
        }
       
        self.ticket.payment_options = paymentOption;
        
        NSString *deliveryOptions = @"";
        if (inPersonSwitch.on) {
            deliveryOptions = @"In Person";
        }
        
        if (electronicSwitch.on) {
            if (deliveryOptions.length > 0) {
                deliveryOptions = [deliveryOptions stringByAppendingFormat:@", %@", @"Electronic"];
            } else {
                deliveryOptions = @"Electronic";
            }
        }
        
        if (postSwitch.on) {
            if (deliveryOptions.length > 0) {
                deliveryOptions = [deliveryOptions stringByAppendingFormat:@", %@", @"Post"];
            } else {
                deliveryOptions = @"Post";
            }
        }
        
        self.ticket.delivery_options = deliveryOptions;
        
        NSString *ticketTypes = @"";
        if (eticketSwitch.on) {
            ticketTypes = @"e-Ticket";
        }
        
        if (paperSwitch.on) {
            if (ticketTypes.length > 0) {
                ticketTypes = [ticketTypes stringByAppendingFormat:@", %@", @"Paper"];
            } else {
                ticketTypes = @"Paper";
            }
        }
        
        self.ticket.ticket_type = ticketTypes;
        
        self.ticket.ticket_desc = self.descriptionTextView.text;
        
        // selected category
        if (self.categoriesCell.selectedCategory) {
           self.event.category_id = self.categoriesCell.selectedCategory;
        }
        
        PreviewViewController *vc = (PreviewViewController *)segue.destinationViewController;
        vc.event = self.event;
        vc.ticket = self.ticket;
        vc.photos = photos;
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
            self.event = result[@"CustomObject"];
            if (self.event.thumb) {
                if (!self.photosPreviewCell.photos) {
                    self.photosPreviewCell.photos = [NSMutableArray new];
                }
                [self.photosPreviewCell.photos insertObject:[UIImage imageWithData:self.event.thumb] atIndex:0];
                [self.tableView reloadData];
            }
            
            self.locationField.text = [DataManager eventLocation:self.event];
            self.locationField.enabled = NO;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"hh:mm dd/MM/yyyy";
            
            self.startDateField.text =  [formatter stringFromDate:self.event.date];
            self.endDateField.text = [formatter stringFromDate:self.event.endDate];
            
            self.startDateField.enabled = self.endDateField.enabled = NO;
            
            self.categoriesCell.selectedCategory = self.event.category_id;
            self.categoriesCell.readOnly = YES;
            [self.categoriesCell refresh];
            
        }
       
    }
    
    if (textField == self.locationField) {
        NSDictionary *placeInfo = result[@"CustomObject"];
        
        [WebServiceManager fetchLocationDetails:placeInfo[@"place_id"] completion:^(id response, NSError *error) {
            if ([response[@"status"] isEqualToString:@"OK"]) {
                NSArray *addressComponents = response[@"result"][@"address_components"];
                
                for (NSDictionary *component in addressComponents) {
                    
                    if ([component[@"types"] containsObject:@"route"]) {
                        self.event.address = component[@"long_name"];
                    }
                    
                    if ([component[@"types"] containsObject:@"locality"]) {
                        self.event.city = component[@"long_name"];
                    }
                    
                    if ([component[@"types"] containsObject:@"postal_code"]) {
                        self.event.postalCode = component[@"long_name"];
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

- (void)nextDidPressed:(ZSTextField*)textField {
    if (textField == self.priceField) {
        [self.faceValueField becomeFirstResponder];
    }
    
    if (textField == self.faceValueField) {
        [self.ticketsCountField becomeFirstResponder];
    }
    
    if (textField == self.ticketsCountField) {
        [self.ticketTypeField becomeFirstResponder];
    }
}

- (void)previousDidPressed:(ZSTextField*)textField {
    
    if (textField == self.priceField) {
        [self.endDateField becomeFirstResponder];
    }
    
    if (textField == self.faceValueField) {
        [self.priceField becomeFirstResponder];
    }
    
    if (textField == self.ticketsCountField) {
        [self.faceValueField becomeFirstResponder];
    }
}

#pragma mark ZSDatePickerDelegate 

- (void)pickerDidPressDone:(ZSDatePicker*)picker withDate:(NSDate *)date {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm dd/MM/yyyy";
    
    if (picker == startDatePicker) {
        self.startDateField.text = [formatter stringFromDate:date];
        [self.startDateField resignFirstResponder];
    }

    if (picker == endDatePicker) {
        self.endDateField.text = [formatter stringFromDate:date];
        [self.endDateField resignFirstResponder];
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

- (void)pickerViewDidPressDone:(ZSPickerView *)picker withInfo:(id)selectionInfo {

    self.changed = YES;

    
    if (picker == ticketTypePicker) {
        
        self.ticketTypeField.text = selectionInfo;
        [self.ticketTypeField resignFirstResponder];
    }
}

- (void)pickerViewDidPressCancel:(ZSPickerView *)picker {
    if (picker == ticketTypePicker) {
        [self.ticketTypeField resignFirstResponder];
    }

}

- (void)didSelectedCategories:(NSArray*)categories {
    if (categories.count) {
        lblCategory.textColor = [UIColor darkGrayColor];
        self.changed = YES;
    }
}

- (IBAction)cashChanged:(id)sender {
    paypalSwitch.on = !cashSwitch.on;
    if(cashSwitch.on) {
        lblPayment.textColor = [UIColor darkGrayColor];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)paypalChanged:(id)sender {
    cashSwitch.on = !paypalSwitch.on;
    if(paypalSwitch.on) {
        lblPayment.textColor = [UIColor darkGrayColor];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)inPersonChanged:(id)sender {
    if(inPersonSwitch.on) {
        lbldelivery.textColor = [UIColor darkGrayColor];
    }
}

- (IBAction)electronicChanged:(id)sender {
    if(electronicSwitch.on) {
        lbldelivery.textColor = [UIColor darkGrayColor];
    }
}

- (IBAction)postChanged:(id)sender {
    if(postSwitch.on) {
        lbldelivery.textColor = [UIColor darkGrayColor];
    }
}

- (IBAction)eticketChanged:(id)sender {
    paperSwitch.on = !eticketSwitch.on;
    if(eticketSwitch.on) {
        lblTicketType.textColor = [UIColor darkGrayColor];
    }
}

- (IBAction)paperChanged:(id)sender {
    eticketSwitch.on = !paperSwitch.on;
    if(paperSwitch.on) {
        lblTicketType.textColor = [UIColor darkGrayColor];
        eticketSwitch.on = !paperSwitch.on;
    }

}

#pragma mark UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self fbLogin];
    }
}

#pragma mark Fb login

- (void)fbLogin {
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    [FBSession openActiveSessionWithReadPermissions:@[@"email", @"user_birthday", @"user_location"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      
                                      if (error) {
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                          [alert show];
                                          
                                          [loadingView hide];
                                      } else {
                                          if (state == FBSessionStateOpen) {
                                              
                                              FBRequest *request = [FBRequest requestForMe];
                                              [request.parameters setValue:@"id,name,first_name,last_name,email,picture,birthday,location" forKey:@"fields"];
                                              
                                              [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
                                                  if (user) {
                                                      
                                                      NSString *birtday = nil;
                                                      if(user.birthday.length > 0) {
                                                          // change date format from MM/DD/YYYY to DD/MM/YYYY
                                                          NSArray *dateArray = [user.birthday componentsSeparatedByString:@"/"];
                                                          dateArray = @[ dateArray[1], dateArray[0], dateArray[2]];
                                                          birtday = [dateArray componentsJoinedByString:@"/"];
                                                      }
                                                      
                                                      NSDictionary *params = @{ @"name" : user.first_name,
                                                                                @"surname": user.last_name,
                                                                                @"email" : user[@"email"],
                                                                                @"password" : [NSString stringWithFormat:@"fb%@", user.objectID],
                                                                                @"fb_id" : user.objectID,
                                                                                @"date_of_birth": birtday.length > 0 ? birtday : @"",
                                                                                @"city": user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London",
                                                                                @"photo_url": [NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID],//user[@"picture"][@"data"][@"url"],
                                                                                @"device_uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
                                                                                @"device_brand":@"Apple",
                                                                                @"device_model": [[UIDevice currentDevice] platformString],
                                                                                @"device_os":[[UIDevice currentDevice] systemVersion],
                                                                                @"device_location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ]
                                                                                };
                                                      
                                                      
                                                      [WebServiceManager signUp:params completion:^(id response, NSError *error) {
                                                          NSLog(@"response %@", response);
                                                          if (error) {
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                              [alert show];
                                                              
                                                              [loadingView hide];
                                                          } else {
                                                              if (response) {
                                                                  
                                                                  if (response[@"authentication_token"]) {
                                                                      [AppManager sharedManager].token = response[@"authentication_token"];
                                                                      
                                                                      [AppManager sharedManager].userInfo = [@{ @"id":response[@"id"], @"fb_id" : user.objectID, @"email":user[@"email"], @"name": user.first_name, @"photo_url":[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID], @"city":user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London"} mutableCopy];
                                                                      
                                                                      if ([self shouldPerformSegueWithIdentifier:@"PreviewSegue" sender:self]) {
                                                                          [self performSegueWithIdentifier:@"PreviewSegue" sender:self];
                                                                      }
                                                                  } else {
                                                                      
                                                                      // login
                                                                      NSDictionary *params = @{ @"email" : user[@"email"],
                                                                                                @"password" : [NSString stringWithFormat:@"fb%@", user.objectID]
                                                                                                };
                                                                      
                                                                      [WebServiceManager signIn:params completion:^(id response, NSError *error) {
                                                                          NSLog(@"response %@", response);
                                                                          if (error ) {
                                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                              [alert show];
                                                                          } else {
                                                                              
                                                                              if (response) {
                                                                                  
                                                                                  if ([response[@"success"] boolValue]) {
                                                                                      [AppManager sharedManager].token = response[@"auth_token"];
                                                                                      
                                                                                      [AppManager sharedManager].userInfo = [@{@"id":response[@"id"], @"email":user[@"email"], @"name": user.first_name, @"surname": response[@"surname"], @"allow_dingo_emails": response[@"allow_dingo_emails"], @"allow_push_notifications":  response[@"allow_push_notifications"], @"fb_id":user.objectID, @"photo_url":[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID], @"city" : user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London"} mutableCopy];
                                                                                      
                                                                                      if ([self shouldPerformSegueWithIdentifier:@"PreviewSegue" sender:self]) {
                                                                                          [self performSegueWithIdentifier:@"PreviewSegue" sender:self];
                                                                                      }
                                                                                      
                                                                                  } else {
                                                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                      [alert show];
                                                                                  }
                                                                                  
                                                                              } else {
                                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                  [alert show];
                                                                              }
                                                                          }
                                                                      }];
                                                                      
                                                                  }
                                                                  
                                                              } else {
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign up, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                  [alert show];
                                                              }
                                                              
                                                              [loadingView hide];
                                                          }
                                                          
                                                          
                                                      }];
                                                  } else {
                                                      [loadingView hide];
                                                  }
                                                  
                                                  
                                              }];
                                          } else {
                                              [loadingView hide];
                                          }
                                      }
                                      
                                  }];
}




@end
