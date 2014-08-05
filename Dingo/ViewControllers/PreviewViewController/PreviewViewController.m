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
#import "ZSLoadingView.h"
#import "AppManager.h"

static const NSUInteger photosCellIndex = 1;

@interface PreviewViewController ()

@property (nonatomic, weak) IBOutlet ProposalCell *proposalCell;
@property (nonatomic, weak) IBOutlet PhotosPreviewCell *photosPreviewCell;
@property (nonatomic, weak) IBOutlet UILabel *ticketsCountlabel;
@property (nonatomic, weak) IBOutlet UILabel *faceValueLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *paymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
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
    self.ticketTypeLabel.text = self.ticket.ticket_type;
    self.deliveryLabel.text = self.ticket.delivery_options;
    
    [self.proposalCell buildWithData:self.event];
    
    self.sellerNameLabel.text = [AppManager sharedManager].userInfo[@"name"];
    self.sellerInfolabel.text = @"";
    self.sellerImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[AppManager sharedManager].userInfo[@"photo_url"]]]];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case photosCellIndex:
            if (self.photosPreviewCell.photos.count == 0) {
                return 0;
            }
            break;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UIActions

- (IBAction)confirm {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm dd/MM/yyyy";
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    if (self.event.event_id.length == 0) {
        
        // get event location form address and then create event
        [WebServiceManager addressToLocation:[DataManager eventLocation:self.event] completion:^(id response, NSError *error) {
            
            NSString *location = @"";
            if ([response[@"status"] isEqualToString:@"OK"]) {
                NSArray *results = response[@"results"];
                if (results.count > 0) {
                    NSDictionary *result = results[0];
                    
                    location = [NSString stringWithFormat:@"%@,%@", result[@"geometry"][@"location"][@"lat"], result[@"geometry"][@"location"][@"lng"]];
                }
                
            }
            
            // Create event
            NSDictionary *params = @{ @"category_id" : self.event.category_id,
                                      @"name" : self.event.name,
                                      @"date" : [formatter stringFromDate:self.event.date],
                                      @"end_date" : [formatter stringFromDate:self.event.endDate],
                                      @"address" : self.event.address.length > 0 ? self.event.address : @"",
                                      @"city" : self.event.city.length > 0 ? self.event.city : @"",
                                      @"postcode" : self.event.postalCode.length > 0 ? self.event.postalCode : @"",
                                      @"location" : location,
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
                                                  @"face_value_per_ticket" : [self.ticket.face_value_per_ticket stringValue],
                                                  @"ticket_type" : self.ticket.ticket_type
                                                  };
                        
                        [WebServiceManager createTicket:params photos:self.photos completion:^(id response, NSError *error) {
                            if (response[@"id"]) {
                                // ticket created
                                [self.navigationController.viewControllers[0] setSelectedIndex:0];
                                [self.navigationController popToRootViewControllerAnimated:YES];

                            }
                            
                            [loadingView hide];
                            
                        }];
                        
                    }
                } else {
                    [loadingView hide];
                }
                
            }];
            
        }];
        

    } else {
        // create ticket
        NSDictionary *params = @{ @"event_id" : self.event.event_id,
                                  @"price" : [self.ticket.price stringValue],
                                  @"seat_type" : self.ticket.seat_type.length> 0 ? self.ticket.seat_type : @"",
                                  @"description" : self.ticket.ticket_desc.length > 0 ? self.ticket.ticket_desc : @"",
                                  @"delivery_options" : self.ticket.delivery_options.length > 0 ? self.ticket.delivery_options : @"",
                                  @"payment_options" : self.ticket.payment_options.length > 0 ? self.ticket.payment_options : @"",
                                  @"number_of_tickets" : [self.ticket.number_of_tickets stringValue],
                                  @"face_value_per_ticket" : [self.ticket.face_value_per_ticket stringValue],
                                  @"ticket_type" : self.ticket.ticket_type
                                  };
        
        [WebServiceManager createTicket:params photos:self.photos completion:^(id response, NSError *error) {
            if (response[@"id"]) {
                // ticket created
                [self.navigationController.viewControllers[0] setSelectedIndex:0];
                [self.navigationController popToRootViewControllerAnimated:YES];

            }
            
            [loadingView hide];
            
        }];
    }

    
    
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark



@end
