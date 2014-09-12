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
#import <MapKit/MapKit.h>
#import "MapViewController.h"

static const NSUInteger photosCellIndex = 1;
static const NSUInteger commentCellIndex = 4;

@interface PreviewViewController () {
    
    __weak IBOutlet UILabel *lblTicketCount;
    __weak IBOutlet UILabel *lblFaceValue;
    __weak IBOutlet UILabel *lblComment;
    __weak IBOutlet UILabel *lblTicketType;
    __weak IBOutlet UILabel *lblPayment;
    __weak IBOutlet UILabel *lblDelivery;
}

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
@property (weak, nonatomic) IBOutlet UIButton *offerNewButton;
@property (nonatomic, weak) IBOutlet UIImageView *sellerImageView;
@property (nonatomic, weak) IBOutlet UILabel *sellerNameLabel;
@property (weak, nonatomic) IBOutlet MKMapView *locationMap;

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
    
    lblTicketCount.font = lblFaceValue.font = lblComment.font = lblTicketType.font = lblPayment.font = lblDelivery.font = [DingoUISettings lightFontWithSize:14];
    
    self.ticketsCountlabel.font = self.faceValueLabel.font = self.descriptionTextView.font =  self.paymentLabel.font =  self.ticketTypeLabel.font =  self.deliveryLabel.font = [DingoUISettings lightFontWithSize:14];
    
    self.contactCellerButton.titleLabel.font = self.requestToBuyButton.titleLabel.font = self.offerNewButton.titleLabel.font = [DingoUISettings lightFontWithSize:16];
    
    self.sellerNameLabel.font = [DingoUISettings fontWithSize:19];
    
    self.ticketsCountlabel.text = [self.ticket.number_of_tickets stringValue];
    self.faceValueLabel.text = [self.ticket.face_value_per_ticket stringValue];
    self.descriptionTextView.text = self.ticket.ticket_desc;
    self.paymentLabel.text = self.ticket.payment_options;
    self.ticketTypeLabel.text = self.ticket.ticket_type;
    self.deliveryLabel.text = self.ticket.delivery_options;
    
    [self.proposalCell buildWithData:self.event];
    
    [WebServiceManager addressToLocation:[DataManager eventLocation:self.event] completion:^(id response, NSError *error) {
        
        if ([response[@"status"] isEqualToString:@"OK"]) {
            NSArray *results = response[@"results"];
            if (results.count > 0) {
                NSDictionary *result = results[0];
                
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([result[@"geometry"][@"location"][@"lat"] doubleValue], [result[@"geometry"][@"location"][@"lng"] doubleValue]);
                MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
                MKCoordinateRegion region = {coord, span};
                [self.locationMap setRegion:region];
            }
            
        }
    }];

    
    self.sellerNameLabel.text = [AppManager sharedManager].userInfo[@"name"];
    
    self.sellerImageView.image = nil;
    [WebServiceManager imageFromUrl:[AppManager sharedManager].userInfo[@"photo_url"] completion:^(id response, NSError *error) {
        if (response) {
            self.sellerImageView.image = [UIImage imageWithData:response];
        }
    }];
    
   self.tableView.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case photosCellIndex:
            if (self.photosPreviewCell.photos.count == 0) {
                return 0;
            }
            break;
        case commentCellIndex: {
            CGSize size = [self.descriptionTextView sizeThatFits:CGSizeMake(self.descriptionTextView.frame.size.width, FLT_MAX)];
            if (self.descriptionTextView.text.length == 0) {
                return 36;
            } else {
                CGRect frame = self.descriptionTextView.frame;
                frame.size.height = size.height;
                self.descriptionTextView.frame = frame;
                return size.height + 20;
            }
            
            break;
        }
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"PreviewMapSegue"]) {
        
        UINavigationController *navController = segue.destinationViewController;
        MapViewController *vc = navController.viewControllers[0];
        vc.event = self.event;
        
    }
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
            if (!error ) {
                if (response[@"id"]) {
                    // ticket created
                    [self.navigationController.viewControllers[0] setSelectedIndex:0];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                } else {
                    [AppManager showAlert:@"Unable to create ticket."];
                }
                
            } else {
                [AppManager showAlert:[error localizedDescription]];
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
