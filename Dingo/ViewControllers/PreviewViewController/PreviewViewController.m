//
//  PreviewViewController.m
//  Dingo
//
//  Created by logan on 6/20/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "PreviewViewController.h"

#import "ProposalCell.h"
#import "PhotosPreviewCell.h"

@interface PreviewViewController ()

@property (nonatomic, weak) IBOutlet ProposalCell *proposalCell;
@property (nonatomic, weak) IBOutlet PhotosPreviewCell *photosPreviewCell;
@property (nonatomic, weak) IBOutlet UILabel *ticketsCountlabel;
@property (nonatomic, weak) IBOutlet UILabel *faceValueLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *paymentLabel;
@property (nonatomic, weak) IBOutlet UITextView *collectionTextView;
@property (nonatomic, weak) IBOutlet UIButton *contactCellerButton;
@property (nonatomic, weak) IBOutlet UIButton *requestToBuyButton;
@property (nonatomic, weak) IBOutlet UIImageView *sellerImageView;
@property (nonatomic, weak) IBOutlet UILabel *sellerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sellerInfolabel;

@end

@implementation PreviewViewController

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    self.contactCellerButton.enabled = NO;
    self.requestToBuyButton.enabled = NO;
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photosPreviewCell.photos = [self.photos mutableCopy];
    
    self.ticketsCountlabel.text = [self.ticket.number_of_tickets stringValue];
    self.faceValueLabel.text = [self.ticket.face_value_per_ticket stringValue];
    self.descriptionTextView.text = self.ticket.ticket_desc;
    self.paymentLabel.text = self.ticket.payment_options;
    
//    [self.proposalCell setName:self.event.name];
//    [self.proposalCell setLocation:self.event.address];
    
    [self.proposalCell buildWithData:self.event];
}

#pragma mark - UIActions

- (IBAction)confirm {
    [self back];
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
