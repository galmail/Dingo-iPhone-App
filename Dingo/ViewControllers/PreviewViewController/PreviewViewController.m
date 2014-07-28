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

#import "WebServiceManager.h"

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
    
    [self.proposalCell buildWithData:self.event];
}

#pragma mark - UIActions

- (IBAction)confirm {
//    [self back];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm dd/MM/yyyy";
    
    if (self.event.event_id.length == 0) {
        // Create event
        NSDictionary *params = @{ @"category_id" : self.event.category_id,
                                  @"name" : self.event.name,
                                  @"date" : [formatter stringFromDate:self.event.date],
                                  @"end_date" : [formatter stringFromDate:self.event.endDate],
                                  @"address" : self.event.address,
                                  @"city" : self.event.city,
                                  @"postcode" : self.event.postalCode,
                                  @"image" : self.event.thumb != nil ? self.event.thumb : @""
                                  };
        
        [WebServiceManager createEvent:params completion:^(id response, NSError *error) {
            NSLog(@"response %@", response);
            
            if (response) {
                NSString *eventID = response[@"id"];
                if (eventID.length > 0) {
                    
                    // create ticket
                    NSDictionary *params = @{ @"event_id" : eventID,
                                              @"price" : [self.ticket.price stringValue],
                                              @"seat_type" : self.ticket.seat_type.length> 0 ? self.ticket.seat_type : @"",
                                              @"description" : self.ticket.ticket_desc.length > 0 ? self.ticket.ticket_desc : @"",
                                              @"delivery_options" : self.ticket.delivery_options.length > 0 ? self.ticket.delivery_options : @"",
                                              @"payment_options" : self.ticket.payment_options.length > 0 ? self.ticket.payment_options : @"",
                                              @"number_of_tickets" : [self.ticket.number_of_tickets stringValue],
                                              @"face_value_per_ticket" : [self.ticket.face_value_per_ticket stringValue]
                                              };
                    
                    [WebServiceManager createTicket:params photos:self.photos completion:^(id response, NSError *error) {
                        if (response[@"id"]) {
                            // ticket created
                            
                            [self.navigationController popViewControllerAnimated:NO];
                            [self.navigationController.tabBarController setSelectedIndex:0];
                        }
                        
                    }];
                    
                }
            }
            
        }];
    }

    
    
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
