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
#import "AppDelegate.h"

#import "NSString+DingoFormatting.h"
#import "PayPalMobile.h"


//static const CGFloat paypalCellShrinkedHeight = 120;
static const CGFloat paypalCellExpandedHeight = 240;

static const NSUInteger previewPhotosCellIndex = 8;
static const NSUInteger editPhotosCellIndex = 9;
static const NSUInteger uploadPhotosCellIndex = 10;
static const NSUInteger payPalCellIndex = 11;
static const NSUInteger previewCellIndex = 14;
static const NSUInteger comfirmCellIndex = 15;

NSString *authorization_code;
NSString *access_token;

@interface ListTicketsViewController () <UITextFieldDelegate, UITableViewDataSource, UploadPhotosVCDelegate, ZSTextFieldDelegate, ZSDatePickerDelegate , ZSPickerDelegate ,CategorySelectionDelegate, UITextViewDelegate, PayPalProfileSharingDelegate> {
    
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
    ZSPickerView *selectCategoryPicker;
    ZSPickerView *deliveryPicker;

    __weak IBOutlet UISwitch *cashSwitch;
    __weak IBOutlet UISwitch *paypalSwitch;
    __weak IBOutlet UISwitch *inPersonSwitch;
    __weak IBOutlet UISwitch *electronicSwitch;
    __weak IBOutlet UISwitch *postSwitch;
    __weak IBOutlet UISwitch *eticketSwitch;
    __weak IBOutlet UISwitch *paperSwitch;
    
    BOOL isEditing;
    BOOL isUploadingImage;
    BOOL haveTapButton;
    BOOL isPreviewing;
    
    NSMutableArray *photos;
	
	PayPalConfiguration *payPalConfig;
	
	NSString *payPalKey;
}

@property (nonatomic, weak) IBOutlet ZSTextField *nameField;
@property (weak, nonatomic) IBOutlet ZSTextField *locationField;
@property (nonatomic, weak) IBOutlet UITextField *startDateField;
@property (nonatomic, weak) IBOutlet UITextField *endDateField;
@property (nonatomic, weak) IBOutlet ZSTextField *priceField;
@property (nonatomic, weak) IBOutlet ZSTextField *faceValueField;
@property (nonatomic, weak) IBOutlet ZSTextField *ticketsCountField;
@property (nonatomic, weak) IBOutlet ZSTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet PhotosPreviewCell *photosPreviewCell;
@property (weak, nonatomic) IBOutlet UITextField *typeTicketField;

@end

@implementation ListTicketsViewController

#pragma mark - UITableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    lblName.font = lblLocation.font = lblFromDate.font = lblToDate.font = lblPrice.font = lblFaceValue.font = lblTicketCount.font = lblTicketType.font = [DingoUISettings fontWithSize:14];
    lblPayment.font = lbldelivery.font = lbleTicket.font = lblPaper.font = lblCash.font = lblPaypal.font = lblInPerson.font = lblElectrical.font = lblPost.font = lblDescription.font = [DingoUISettings fontWithSize:14];
    
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
    [ticketTypePicker setBackgroundColor:[UIColor whiteColor]];
    self.typeTicketField.inputView = ticketTypePicker;

    selectCategoryPicker = [[ZSPickerView alloc] initWithItems:[NSArray arrayWithObjects:@"Concerts",@"Nightlife",@"Sport",@"Theatre & Comedy", nil] allowMultiSelection:NO];
    selectCategoryPicker.delegate = self;
    [selectCategoryPicker setBackgroundColor:[UIColor whiteColor]];
    
    self.descriptionTextView.placeholder = @"Add any additional comments about the tickets or collection.";
    [self.descriptionTextView showToolbarWithDone];
    [self.nameField showToolbarWithDone];
	
	payPalConfig = [[PayPalConfiguration alloc] init];
	payPalConfig.languageOrLocale = @"en";
	payPalConfig.merchantName = PAYPAL_MERCHANT_NAME;
	payPalConfig.merchantPrivacyPolicyURL = PAYPAL_MERCHANT_PRIVACY_POLICY_URL;
	payPalConfig.merchantUserAgreementURL = PAYPAL_MERCHANT_USER_AGREEMENT_URL;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	DLog(@"self.ticket: %@", self.ticket);
   
    self.parentViewController.navigationItem.title = self.navigationItem.title;
    
    if (!self.ticket && !self.event) {
        self.changed = NO;
        
        self.ticket = [[Ticket alloc] initWithEntity:[NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
        self.event = [[Event alloc] initWithEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
        
        isEditing = NO;
    }
    
    if ([AppManager sharedManager].draftTicket) {
        
        self.changed = YES;
        
        self.nameField.text = [AppManager sharedManager].draftTicket[@"name"];
        self.locationField.text= [AppManager sharedManager].draftTicket[@"location"];
        self.startDateField.text = [AppManager sharedManager].draftTicket[@"startDate"];
        self.endDateField.text = [AppManager sharedManager].draftTicket[@"endDate"];
        self.descriptionTextView.text = [AppManager sharedManager].draftTicket[@"description"];
        if ([[AppManager sharedManager].draftTicket[@"price"] floatValue]>0) {
            self.priceField.text = [NSString stringWithFormat:@"£%@",[AppManager sharedManager].draftTicket[@"price"]];
            self.faceValueField.text= [NSString stringWithFormat:@"£%@",[AppManager sharedManager].draftTicket[@"faceValue"]];
        }else{
        self.priceField.text = [AppManager sharedManager].draftTicket[@"price"];
        self.faceValueField.text= [AppManager sharedManager].draftTicket[@"faceValue"];
        }
        self.ticketsCountField.text = [AppManager sharedManager].draftTicket[@"ticketCount"];
        self.typeTicketField.text = [AppManager sharedManager].draftTicket[@"ticketType"];

        NSString *paymentOptions = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_event_paymentOptions"];
        paypalSwitch.on = [paymentOptions rangeOfString:@"PayPal"].location != NSNotFound;
        cashSwitch.on = [paymentOptions rangeOfString:@"Cash in person"].location != NSNotFound;

        NSString *deliveryOptions = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_event_deliveryOptions"];
        inPersonSwitch.on = [deliveryOptions rangeOfString:@"In Person"].location != NSNotFound;
        electronicSwitch.on = [deliveryOptions rangeOfString:@"Electronic"].location != NSNotFound;
        postSwitch.on =  [deliveryOptions rangeOfString:@"Post"].location != NSNotFound;
        
        photos = [AppManager sharedManager].draftTicket[@"photos"];
        if (!photos) {
            photos = [NSMutableArray new];
        }
            
        self.photosPreviewCell.photos = [photos mutableCopy];
        if (self.event.thumb) {
//            [self.photosPreviewCell.photos insertObject:[UIImage imageWithData:self.event.thumb] atIndex:0];
        }

        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm dd/MM/yyyy";
        

        self.event.name = self.nameField.text;
        self.event.address = @"NEW EVENT";
        
        self.event.date = [formatter dateFromString:self.startDateField.text];
        self.event.endDate = [formatter dateFromString:self.startDateField.text];
        self.ticket.price = [NSNumber numberWithFloat:[[self.priceField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue]];
        self.ticket.face_value_per_ticket = [NSNumber numberWithFloat:[[self.faceValueField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue]];
        self.ticket.number_of_tickets = [NSNumber numberWithInt:[self.ticketsCountField.text intValue]];
        self.ticket.ticket_desc = self.descriptionTextView.text ;
        self.ticket.ticket_type = self.typeTicketField.text;
        
        self.ticket.ticket_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_ticket_ticket_id"];
        self.event.event_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_event_event_id"];
        self.event.city = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_event_city"];
        self.event.postalCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_event_postcode"];
        self.event.thumbUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_event_thumbURL"];
        self.event.category_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDingo_event_categoryID"];

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
        self.typeTicketField.text = nil;
        
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
        
        [self.tableView reloadData];
    } else {
        
    }
    
    if (isUploadingImage) {
        isUploadingImage = NO;
        if ([photos count] > 0) {
            self.changed = YES;
        }
    }
    
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"kDingo_ticket_editTicket"] boolValue]) {
        [self.nameField setUserInteractionEnabled:false];
        [self.locationField setUserInteractionEnabled:false];
        [self.startDateField setUserInteractionEnabled:false];
        [self.endDateField setUserInteractionEnabled:false];
    }else{
        [self.nameField setUserInteractionEnabled:true];
        [self.locationField setUserInteractionEnabled:true];
        [self.startDateField setUserInteractionEnabled:true];
        [self.endDateField setUserInteractionEnabled:true];
        _nameField.clearButtonMode = UITextFieldViewModeUnlessEditing;
        _startDateField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    }
    
    _priceField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    _faceValueField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    _ticketsCountField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    _typeTicketField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    
    //display tick if logged into PayPal
    NSString *PayPalInfo =[[AppManager sharedManager].userInfo valueForKey:@"paypal_account"];
    //[AppManager showAlert:[NSString stringWithFormat: @"Stored for user is %@.", PayPalInfo]];
    
    if (PayPalInfo.length>4) {
        [self displayTick];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
	
	DLog(@"self.ticket: %@", self.ticket);
	
    if (!isUploadingImage) {
        if (!isPreviewing) {
            NSLog(@"change ticket");
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_ticket_ticket_id"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDingo_ticket_editTicket"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
	self.ticket = nil;
	self.event = nil;
}


#pragma mark -

- (void)setTicket:(Ticket*)ticket event:(Event*)event {
   
    self.nameField.text = event.name;
    self.locationField.text = [DataManager eventLocation:event];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm dd/MM/yyyy";
    
    self.startDateField.text = [formatter stringFromDate:event.date];
    self.endDateField.text = [formatter stringFromDate:event.endDate];
    
    self.locationField.enabled = NO;
    self.startDateField.enabled = NO;
    self.endDateField.enabled = NO;
    
    self.descriptionTextView.text = ticket.ticket_desc;
	
	//old
	//self.priceField.text = [ticket.price stringValue];
	//self.faceValueField.text= [ticket.face_value_per_ticket stringValue];
	
	//new
	if (ticket.price != nil)
		self.priceField.text = [NSString stringWithCurrencyFormattingForPrice:ticket.price];
	if (ticket.face_value_per_ticket != nil)
		self.faceValueField.text = [NSString stringWithCurrencyFormattingForPrice:ticket.face_value_per_ticket];
	
    self.ticketsCountField.text = [ticket.number_of_tickets stringValue];
    self.typeTicketField.text = ticket.ticket_type;

    NSString *ticketType = ticket.ticket_type;
    eticketSwitch.on = [ticketType rangeOfString:@"e-Ticket"].location != NSNotFound;
    paperSwitch.on = [ticketType rangeOfString:@"Paper"].location != NSNotFound;

    if (ticket.payment_options.length > 0) {
        NSString *paymentOptions = ticket.payment_options;
        paypalSwitch.on = [paymentOptions rangeOfString:@"PayPal"].location != NSNotFound;
        cashSwitch.on = [paymentOptions rangeOfString:@"Cash in person"].location != NSNotFound;
        [[NSUserDefaults standardUserDefaults] setObject:self.ticket.payment_options forKey:@"kDingo_event_paymentOptions"];
    } else {
        paypalSwitch.on = NO;
        cashSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_event_paymentOptions"];
    }
    
    if (ticket.delivery_options.length > 0) {
        NSString *deliveryOptions = ticket.delivery_options;
        inPersonSwitch.on = [deliveryOptions rangeOfString:@"In Person"].location != NSNotFound;
        electronicSwitch.on = [deliveryOptions rangeOfString:@"Electronic"].location != NSNotFound;
        postSwitch.on =  [deliveryOptions rangeOfString:@"Post"].location != NSNotFound;
        [[NSUserDefaults standardUserDefaults] setObject:self.ticket.delivery_options forKey:@"kDingo_event_deliveryOptions"];
    } else {
        inPersonSwitch.on = NO;
        electronicSwitch.on = NO;
        postSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_event_deliveryOptions"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
//        [self.photosPreviewCell.photos insertObject:[UIImage imageWithData:self.event.thumb] atIndex:0];
    }
}

- (void)saveDraft {

    if (isEditing) {
        if (!isUploadingImage ) {
            if (!isPreviewing) {
                return;
            }
        } else {
            isUploadingImage = NO;
        }
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

    [[AppManager sharedManager].draftTicket setValue:self.nameField.text forKey:@"name"];
    [[AppManager sharedManager].draftTicket setValue:self.locationField.text forKey:@"location"];
    [[AppManager sharedManager].draftTicket setValue:self.startDateField.text forKey:@"startDate"];
    [[AppManager sharedManager].draftTicket setValue:self.endDateField.text forKey:@"endDate"];
    [[AppManager sharedManager].draftTicket setValue:[self.priceField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] forKey:@"price"];
    [[AppManager sharedManager].draftTicket setValue:[self.faceValueField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] forKey:@"faceValue"];
    [[AppManager sharedManager].draftTicket setValue:self.ticketsCountField.text forKey:@"ticketCount"];
    [[AppManager sharedManager].draftTicket setValue:self.descriptionTextView.text forKey:@"description"];
    [[AppManager sharedManager].draftTicket setValue:self.typeTicketField.text forKey:@"ticketType"];

    if (!haveTapButton) {

        [[NSUserDefaults standardUserDefaults] setObject:self.event.event_id forKey:@"kDingo_event_event_id"];
        [[NSUserDefaults standardUserDefaults] setObject:self.event.city forKey:@"kDingo_event_city"];
        [[NSUserDefaults standardUserDefaults] setObject:self.event.postalCode forKey:@"kDingo_event_postcode"];
        [[NSUserDefaults standardUserDefaults] setObject:self.event.thumbUrl forKey:@"kDingo_event_thumbURL"];
        [[NSUserDefaults standardUserDefaults] setObject:self.event.category_id forKey:@"kDingo_event_categoryID"];
        [[NSUserDefaults standardUserDefaults] setObject:self.ticket.payment_options forKey:@"kDingo_event_paymentOptions"];
        [[NSUserDefaults standardUserDefaults] setObject:self.ticket.delivery_options forKey:@"kDingo_event_deliveryOptions"];
    }

    if (photos.count) {
        [[AppManager sharedManager].draftTicket setObject:photos forKey:@"photos"];
    }
    
    haveTapButton = NO;
}

- (IBAction)confirm:(id)sender {
    
    NSString *paymentOption = @"";
    if (cashSwitch.on) {
        paymentOption = @"Cash in person";
    }
    
    if (NSSTRING_HAS_DATA([[NSUserDefaults standardUserDefaults] objectForKey:@"paypal_account"])) {
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
    
    NSDictionary *params = @{@"ticket_id":self.ticket.ticket_id,
                             @"price":[self.ticket.price stringValue],
                             @"ticket_type":self.ticket.ticket_type,
                             @"description":self.ticket.ticket_desc.length > 0 ? self.ticket.ticket_desc : @"",
                             @"delivery_options":self.ticket.delivery_options,
                             @"payment_options":self.ticket.payment_options,
                             @"number_of_tickets":[self.ticket.number_of_tickets stringValue],
                             @"face_value_per_ticket":[self.ticket.face_value_per_ticket stringValue]
                             };
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    [WebServiceManager updateTicket:params photos:photos completion:^(id response, NSError *error) {
        NSLog(@"LT response %@", response);
        [loadingView hide];
        
        if (response[@"id"]) {
            [[DataManager shared] addOrUpdateTicket:response];
            [[AppManager sharedManager] saveContext];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [AppManager showAlert:@"Unable to save changes, Please try later"];
        }
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
            //return paypalSwitch.on ? paypalCellExpandedHeight : paypalCellShrinkedHeight;
            return paypalCellExpandedHeight;
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
        
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm dd/MM/yyyy";
        
        if (self.endDateField.text.length > 0) {
            [endDatePicker setDate:[formatter dateFromString:self.endDateField.text]];
        } else if ( self.startDateField.text.length > 0) {
            [endDatePicker setDate:[formatter dateFromString:self.startDateField.text]];
        }
        if (self.startDateField.text.length > 0) {
            [endDatePicker setMinimumDate:[formatter dateFromString:self.startDateField.text]];
        }
    }else if ([textField isEqual:self.priceField]){
        if ([textField.text hasPrefix:@"£"])
            [textField setText:[textField.text stringByReplacingOccurrencesOfString:@"£" withString:@""]];
        
    }else if ([textField isEqual:self.faceValueField]){
        if ([textField.text hasPrefix:@"£"])
            [textField setText:[textField.text stringByReplacingOccurrencesOfString:@"£" withString:@""]];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.nameField) {
        self.locationField.text = @"";
        self.startDateField.text = @"";
        self.endDateField.text = @"";
        
        self.locationField.enabled = YES;
        self.startDateField.enabled = YES;
        self.endDateField.enabled = YES;
    }else if([textField isEqual:self.priceField] || [textField isEqual:self.faceValueField]){
         NSString *priceText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]*)(\\.([0-9]{0,2})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive  error:nil];
        NSUInteger noOfMatches = [regex numberOfMatchesInString:priceText
                                                        options:0
                                                          range:NSMakeRange(0, [priceText length])];
        if (noOfMatches==0){
            return NO;
        }
        return YES;
    }
    
    return YES;
}


//set limit on characters for decription field
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return textView.text.length + (text.length - range.length) <= 220;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.nameField) {
        if (self.nameField.text.length > 0) {
            
            if (self.event.event_id &&  ![self.event.name isEqual:self.nameField.text]) {
                self.event.event_id = nil;
                self.locationField.enabled = NO;
                self.startDateField.enabled = NO;
                self.endDateField.enabled = NO;
            }
            
            self.event.name = self.nameField.text;
            lblName.textColor = [UIColor blackColor];
            self.changed = YES;
        } else {
            self.locationField.text = @"";
            self.startDateField.text = @"";
            self.endDateField.text = @"";
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
            
			float priceFieldValue= [[self.priceField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue];
			
			if (priceFieldValue > 0) {
				float facePriceValue=[[self.faceValueField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue];
				
				if ((priceFieldValue > facePriceValue) &&  self.faceValueField.text.length > 0) {
					[self showFaceValueAlertMessage];
				} else{
					self.ticket.face_value_per_ticket = @([self.faceValueField.text floatValue]); //?
					self.ticket.price = @([self.priceField.text floatValue]);
					
					//new
					self.priceField.text = [NSString stringWithCurrencyFormattingForPrice:self.ticket.price];
					
					self.event.fromPrice = @([self.priceField.text floatValue]);
					lblPrice.textColor = [UIColor blackColor];
					self.changed = YES;
					
					if (![self.priceField.text hasPrefix:@"£"])
						[self.priceField setText:[NSString stringWithFormat:@"£%@",self.priceField.text]];
				}
			} else {
				[self showPriceAlertMessage];
			}
        }
	}

    if (textField == self.faceValueField) {
        if (self.faceValueField.text.length > 0) {
            self.changed = YES;
            
            
            float priceFieldValue= [[self.priceField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue];
            float facePriceValue=[[self.faceValueField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue];
			if (facePriceValue > 0) {
				if ((priceFieldValue > facePriceValue) ) {
					[self showFaceValueAlertMessage];
				} else{
					self.ticket.face_value_per_ticket = @([self.faceValueField.text floatValue]);
					
					//new
					self.faceValueField.text = [NSString stringWithCurrencyFormattingForPrice:self.ticket.face_value_per_ticket];
					
					lblFaceValue.textColor = [UIColor blackColor];
					
					if (![self.faceValueField.text hasPrefix:@"£"])
						[self.faceValueField setText:[NSString stringWithFormat:@"£%@",self.faceValueField.text]];
				}
			} else {
				[self showPriceAlertMessage];
			}
        }
    }

    if (textField == self.ticketsCountField) {
        if (self.ticketsCountField.text.length > 0) {
			int numberOfTickets = [self.ticketsCountField.text intValue];
			if (numberOfTickets > 0) {
				self.ticket.number_of_tickets = @(numberOfTickets);
				lblTicketCount.textColor = [UIColor blackColor];
				self.changed = YES;
			} else {
				[self showTicketNumberMessage];
			}
        }
    }
    
    if (textField == self.typeTicketField) {
        if (self.typeTicketField.text.length > 0) {
            lblTicketType.textColor = [UIColor blackColor];
            self.changed = YES;
        }
    }
}

- (void)showTicketNumberMessage{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Must sell at least one ticket." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
	[alert show];
	[self.ticketsCountField setText:@""];
}

- (void)showPriceAlertMessage{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"All tickets must be listed for at least 1p." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
	[alert show];
	[self.priceField setText:@""];
	[self.faceValueField setText:@""];
}

- (void)showFaceValueAlertMessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Tickets on Dingo can only be sold at face value or below. The Dingo team monitor all listings. Tickets being sold above face value will be removed." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [self.priceField setText:@""];
    [self.faceValueField setText:@""];
}

#pragma mark - Navigation

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if (![[AppManager sharedManager].userInfo[@"fb_id"] length] && [identifier isEqualToString:@"PreviewSegue"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Please login to Facebook to sell tickets." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 101;
        [alert show];
        return NO;
    }
    

    BOOL requiredInfoFilled = YES;
    
    if ([identifier isEqualToString:@"PreviewSegue"]) {
        
        if (self.nameField.text.length == 0) {
            requiredInfoFilled = NO;
            lblName.textColor = [UIColor redColor];
        }
        
        //if (self.locationField.text.length == 0) {
        //    requiredInfoFilled = NO;
        //    lblLocation.textColor = [UIColor redColor];
        //}
        
        if (self.startDateField.text.length == 0) {
            requiredInfoFilled = NO;
            lblFromDate.textColor = [UIColor redColor];
        }
        
        //if (self.endDateField.text.length == 0) {
        //    requiredInfoFilled = NO;
        //    lblToDate.textColor = [UIColor redColor];
        //}
        
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

//        if (!NSSTRING_HAS_DATA([[NSUserDefaults standardUserDefaults] objectForKey:@"paypal_account"])) {
//            requiredInfoFilled = NO;
//            lblPayment.textColor = [UIColor redColor];
//        }
        
        if (self.typeTicketField.text.length == 0) {
            requiredInfoFilled = NO;
            lblTicketType.textColor = [UIColor redColor];
        }

        if (!requiredInfoFilled) {
            [AppManager showAlert:@"Please complete compulsory fields."];
            [self.tableView setContentOffset:CGPointZero];
        }
        
        float priceFieldval=[[self.priceField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue];
        float facePriceVal=[[self.faceValueField.text stringByReplacingOccurrencesOfString:@"£" withString:@""] floatValue];
        
        if ( priceFieldval> facePriceVal) {
            requiredInfoFilled = NO;
            lblPrice.textColor = [UIColor redColor];
            [self showFaceValueAlertMessage];
        }
        
    }

    return requiredInfoFilled;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EditPhotosSegue"] || [segue.identifier isEqualToString:@"UploadPhotosSegue"]) {
        [self saveDraft];

        UploadPhotosViewController *vc = (UploadPhotosViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.mainPhoto = [UIImage imageWithData:self.event.thumb];
        vc.photos = photos;
        isUploadingImage = YES;
        haveTapButton = YES;
    } else if ([segue.identifier isEqualToString:@"PreviewSegue"]) {
        
        isPreviewing = YES;
        
//        NSString *paymentOption = @"";
//        if (cashSwitch.on) {
//            paymentOption = @"Cash in person";
//        }
        
        if (NSSTRING_HAS_DATA([[NSUserDefaults standardUserDefaults] objectForKey:@"paypal_account"])) {
           // if (paymentOption.length > 0) {
            //    paymentOption = [paymentOption stringByAppendingFormat:@", %@", @"PayPal"];
            //} else {
               self.ticket.payment_options= @"PayPal";
           // }
        }else{
            self.ticket.payment_options= @"  ";
        }
       
        
        
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
        self.ticket.ticket_type = self.typeTicketField.text;
        self.ticket.ticket_desc = self.descriptionTextView.text;
        self.ticket.user_id = [NSNumber numberWithDouble:[[AppManager sharedManager].userInfo[@"id"] doubleValue]];
        self.ticket.user_name = [AppManager sharedManager].userInfo[@"name"];
//        self.ticket.user_photo = [AppManager sharedManager].userInfo[@"photo_url"];
        self.ticket.user_email = [AppManager sharedManager].userInfo[@"email"];
        self.ticket.facebook_id = [AppManager sharedManager].userInfo[@"fb_id"];
        self.ticket.event_id = self.event.event_id;
        
        if (!self.event) {
            self.event = [[Event alloc] initWithEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:[AppManager sharedManager].managedObjectContext] insertIntoManagedObjectContext:nil];
            NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
            formatter.dateFormat = @"HH:mm dd/MM/yyyy";
            self.event.name = self.nameField.text;
            self.event.address = self.locationField.text;
            self.event.date = [formatter dateFromString:self.startDateField.text];
            self.event.endDate = [formatter dateFromString:self.endDateField.text];
            
            
            
        }
        
        PreviewViewController *vc = (PreviewViewController *)segue.destinationViewController;
        vc.event = self.event;
        vc.ticket = self.ticket;
        vc.photos = photos;
        if (NSSTRING_HAS_DATA(self.ticket.ticket_id)) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDingo_ticket_editTicket"];
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDingo_ticket_editTicket"];
        }
        vc.editTicket = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDingo_ticket_editTicket"];
        
        [self saveDraft];

    }
    
}

#pragma mark ZSTextFieldDelegate

- (NSArray *)dataForPopoverInTextField:(ZSTextField *)textField {
    
    if (textField == self.nameField) {
        
        self.event = nil;
        
        NSArray* events = [[DataManager shared] allEventsWithAndWithoutTickets];
        NSMutableArray *dataForPopover = [NSMutableArray new];
        
        for (Event *tmpEvent in events) {
            //old not with date
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
                self.event.thumb = nil;
//                if (!self.photosPreviewCell.photos) {
//                    self.photosPreviewCell.photos = [NSMutableArray new];
//                }
//                [self.photosPreviewCell.photos insertObject:[UIImage imageWithData:self.event.thumb] atIndex:0];
                [self.tableView reloadData];
            }
            
            self.locationField.text = [DataManager eventLocation:self.event];
            self.locationField.enabled = NO;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"HH:mm dd/MM/yyyy";
            
            self.startDateField.text =  [formatter stringFromDate:self.event.date];
            self.endDateField.text = [formatter stringFromDate:self.event.endDate];
            self.startDateField.enabled = self.endDateField.enabled = NO;
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
        [self.typeTicketField becomeFirstResponder];
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
    self.changed = YES;

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
        self.typeTicketField.text = selectionInfo;
        [self.typeTicketField resignFirstResponder];
    }
}

- (void)pickerViewDidPressCancel:(ZSPickerView *)picker {

    if (picker == ticketTypePicker) {
        [self.typeTicketField resignFirstResponder];
    }
}

- (IBAction)cashChanged:(id)sender {
    paypalSwitch.on = !cashSwitch.on;
    if(cashSwitch.on) {
        lblPayment.textColor = [UIColor darkGrayColor];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.changed = YES;
}

- (IBAction)paypalChanged:(id)sender {
	[self saveDraft];
    
    //check if user is logged in via FB, if not display alert
    if (![[AppManager sharedManager].userInfo[@"fb_id"] length]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Please login to Facebook to sell tickets." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 201;
        [alert show];
    } else {
	
	DLog(@"self.event.test: %i", [self.event.test boolValue]);
	[PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];

	// Choose whichever scope-values apply in your case. See `PayPalOAuthScopes.h` for a complete list of available scope-values.
	NSSet *scopeValues = [NSSet setWithArray:@[kPayPalOAuth2ScopeEmail]];
	
	PayPalProfileSharingViewController *psViewController = [[PayPalProfileSharingViewController alloc] initWithScopeValues:scopeValues
																		 configuration:payPalConfig
																			  delegate:self];
	
	// Present the PayPalProfileSharingViewController
	[self presentViewController:psViewController animated:YES completion:nil];
    }
}

- (IBAction)inPersonChanged:(id)sender {
    if(inPersonSwitch.on) {
        lbldelivery.textColor = [UIColor darkGrayColor];
    }
    self.changed = YES;
}

- (IBAction)electronicChanged:(id)sender {
    if(electronicSwitch.on) {
        lbldelivery.textColor = [UIColor darkGrayColor];
    }
    self.changed = YES;
}

- (IBAction)postChanged:(id)sender {
    if(postSwitch.on) {
        lbldelivery.textColor = [UIColor darkGrayColor];
    }
    self.changed = YES;
}

- (IBAction)eticketChanged:(id)sender {
    paperSwitch.on = !eticketSwitch.on;
    if(eticketSwitch.on) {
        lblTicketType.textColor = [UIColor darkGrayColor];
    }
    self.changed = YES;
}

- (IBAction)paperChanged:(id)sender {
    eticketSwitch.on = !paperSwitch.on;
    if(paperSwitch.on) {
        lblTicketType.textColor = [UIColor darkGrayColor];
        eticketSwitch.on = !paperSwitch.on;
    }
    self.changed = YES;
}

#pragma mark UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //if user pressed Preview
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            [WebServiceManager signInWithFBAndUpdate:YES completion:^(id response, NSError *error) {
                [loadingView hide];
                if (response) {
                    if ([self shouldPerformSegueWithIdentifier:@"PreviewSegue" sender:self]) {
                        [self performSegueWithIdentifier:@"PreviewSegue" sender:self];
                    }
                }else{
                    [WebServiceManager handleError:error];
                }
            }];
        }
    }
    //if user pressed PayPal login
    if (alertView.tag == 201) {
        
        if (buttonIndex == 1) {
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            [WebServiceManager signInWithFBAndUpdate:YES completion:^(id response, NSError *error) {
                [loadingView hide];
                if (response) {
                    [self paypalChanged:nil];
                }else{
                    [WebServiceManager handleError:error];
                }
            }];
        }
    }
}


-(void)displayTick{
    //tick with pictures
    UIImageView *tickPictures=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + 110, 640, 44, 35)];
    [tickPictures setImage:[UIImage imageNamed:@"GreenTick.png"]];
    [tickPictures setTag:1];
    //tick without pictures
    UIImageView *tickNoPictures=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + 110, 532, 44, 35)];
    [tickNoPictures setImage:[UIImage imageNamed:@"GreenTick.png"]];
    [tickNoPictures setTag:2];
    
    [tickPictures removeFromSuperview];
    [[self.view viewWithTag:1] removeFromSuperview];
    
    [tickNoPictures removeFromSuperview];
    [[self.view viewWithTag:2] removeFromSuperview];
    
    if (photos.count == 0) {
        [self.view addSubview:tickNoPictures];
    }
    if (photos.count > 0) {
        [self.view addSubview:tickPictures];
    }
}

#pragma mark PayPalProfileSharingDelegate methods


/// User canceled without consenting.
/// @param profileSharingViewController The PayPalProfileSharingViewController that the user canceled without consenting.
- (void)userDidCancelPayPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController {
	ALog();
	
	//should we remove paypal info ?
//	[[AppManager sharedManager].userInfo removeObjectForKey:@"paypal_account"];
//	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"paypal_account"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
	
	self.changed = YES;
	[self dismissViewControllerAnimated:YES completion:nil];
}

/// User successfully logged in and consented.
/// @param profileSharingViewController The PayPalProfileSharingViewController where the user successfully consented.
/// @param authorization The authorization response, which you will return to your server.
- (void)payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController
			 userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization {
	
	DLog(@"profileSharingAuthorization: %@", profileSharingAuthorization);
	
	authorization_code = profileSharingAuthorization[@"response"][@"code"];

    //new
    [self displayTick];
    [self getPayPalAccessToken];
    
	//old
//	ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
//	[loadingView show];
//	
//	NSDictionary *params = @{@"paypal_account": authorization_code};
//	[WebServiceManager updateProfile:params completion:^(id response, NSError *error) {
//		NSLog(@"updateProfile response %@", response);
//		[loadingView hide];
//		
//        if (error) {
//            [WebServiceManager handleError:error];
//        } else {
//            [[AppManager sharedManager].userInfo setValue: authorization_code forKey:@"paypal_account"];
//            [self displayTick];
//        }
//	}];
	self.changed = YES;
	[self dismissViewControllerAnimated:YES completion:nil];
}


-(void) getPayPalAccessToken{
    
    NSString *clientID = kPaypalProductionID;
    NSString *secret = @"EPCpCBD2ET_au6zrrjr8yBpbBA6D2Fs7Qh0BrecuPaFwhPgR4fmjdA3UxIAD";
    
    NSString *authString = [NSString stringWithFormat:@"%@:%@", clientID, secret];
    NSData * authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *credentials = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [configuration setHTTPAdditionalHeaders:@{ @"Content-Type": @"application/x-www-form-urlencoded", @"client_id": @"secret", @"Authorization": credentials }];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.paypal.com/v1/oauth2/token"]];
    request.HTTPMethod = @"POST";
    
    NSString *dataString = [NSString stringWithFormat: @"grant_type=authorization_code&response_type=token&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=%@", authorization_code];
    NSData *theData = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:theData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *paypalAccessTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            //now use access_token to get verified email address
            access_token = [paypalAccessTokenResponse objectForKey:@"access_token"];
            [self getPayPalEmailAddress];
            // [AppManager showAlert:[NSString stringWithFormat: @"Response is %@.", access_token]];
        }
    }];
    [task resume];
}



-(void) getPayPalEmailAddress{
    NSString *access_tokenWithBearerPrefix = [NSString stringWithFormat: @"Bearer %@", access_token];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [configuration setHTTPAdditionalHeaders:@{ @"Content-Type": @"application/json", @"Authorization": access_tokenWithBearerPrefix }];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.paypal.com/v1/identity/openidconnect/userinfo/?schema=openid"]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *paypalEmailResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSString *verifiedEmailAddress = [paypalEmailResponse objectForKey:@"email"];
            
            NSDictionary *params = @{@"paypal_account": verifiedEmailAddress};
            [WebServiceManager updateProfile:params completion:^(id response, NSError *error) {
                if (error) {
                    [WebServiceManager handleError:error];
                } else {
                    [[AppManager sharedManager].userInfo setValue: verifiedEmailAddress forKey:@"paypal_account"];
                    //[AppManager showAlert:[NSString stringWithFormat: @"Response is %@.", verifiedEmailAddress]];
                }
            }];
        }
    }];
    [task resume];
}


@end
