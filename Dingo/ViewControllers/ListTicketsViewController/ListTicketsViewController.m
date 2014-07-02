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

static const CGFloat paypalCellShrinkedHeight = 72;
static const CGFloat paypalCellExpandedHeight = 130;

static const NSUInteger previewPhotosCellIndex = 10;
static const NSUInteger editPhotosCellIndex = 11;
static const NSUInteger uploadPhotosCellIndex = 12;
static const NSUInteger payPalCellIndex = 13;

@interface ListTicketsViewController () <UITextFieldDelegate, UITableViewDataSource, UploadPhotosVCDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *locationField;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.title = self.navigationItem.title;
}

#pragma mark - UploadPhotosVCDelegate

- (void)displayPhotos:(NSArray *)array {
    self.photosPreviewCell.photos = [array mutableCopy];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.nameField) {
        [self.locationField becomeFirstResponder];
    } else if (textField == self.locationField) {
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

#pragma mark - UIActions

- (IBAction)cashSwitchValueChanged {
    
}

- (IBAction)paypalSwitchValueChanged {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditPhotosSegue"]) {
        UploadPhotosViewController *vc = (UploadPhotosViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.photos = self.photosPreviewCell.photos;
    } else if ([segue.identifier isEqualToString:@"PreviewSegue"]) {
        PreviewViewController *vc = (PreviewViewController *)segue.destinationViewController;
        vc.photos = self.photosPreviewCell.photos;
    }
}

@end
