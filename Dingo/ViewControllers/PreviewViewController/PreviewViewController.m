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
#import "Mixpanel.h"
#import "AppsFlyerTracker.h"
#import "SettingsViewController.h"


static const NSUInteger photosCellIndex = 8;
static const NSUInteger commentCellIndex = 5;

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
@property (strong, nonatomic) IBOutlet UILabel *pricePerTicket;
@property (strong, nonatomic) IBOutlet UILabel *pricePerTicketLabel;

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
    
    self.pricePerTicketLabel.font = lblTicketCount.font = lblFaceValue.font = lblComment.font = lblTicketType.font = lblPayment.font = lblDelivery.font = [DingoUISettings lightFontWithSize:14];
    
    self.pricePerTicket.font = self.ticketsCountlabel.font = self.faceValueLabel.font = self.descriptionTextView.font =  self.paymentLabel.font =  self.ticketTypeLabel.font =  self.deliveryLabel.font = [DingoUISettings lightFontWithSize:14];
    
    self.contactCellerButton.titleLabel.font = self.requestToBuyButton.titleLabel.font = self.offerNewButton.titleLabel.font = [DingoUISettings lightFontWithSize:16];
    
    self.sellerNameLabel.font = [DingoUISettings fontWithSize:19];
    
    self.ticketsCountlabel.text = [self.ticket.number_of_tickets stringValue];
    self.faceValueLabel.text = [NSString stringWithFormat:@"£%@", self.ticket.face_value_per_ticket];
    self.descriptionTextView.text = self.ticket.ticket_desc;
    self.paymentLabel.text = self.ticket.payment_options;
    self.ticketTypeLabel.text = self.ticket.ticket_type;
    self.deliveryLabel.text = self.ticket.delivery_options;
    self.pricePerTicket.text = [NSString stringWithFormat:@"£%@", self.ticket.price];
    
    [self.proposalCell buildWithData:self.event];
    
    [[self.requestToBuyButton layer] setBorderWidth:4];
    [[self.requestToBuyButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
    
    [WebServiceManager addressToLocation:[DataManager eventLocation:self.event] completion:^(id response, NSError *error) {
        
        if ([response[@"status"] isEqualToString:@"OK"]) {
            NSArray *results = response[@"results"];
            if (results.count > 0) {
                NSDictionary *result = results[0];
                
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([result[@"geometry"][@"location"][@"lat"] doubleValue], [result[@"geometry"][@"location"][@"lng"] doubleValue]);
                MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
                MKCoordinateRegion region = {coord, span};
                [self.locationMap setRegion:region];
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = coord;
                [self.locationMap addAnnotation:annotation];
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
        case photosCellIndex-1:
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
            case 9:
            [super tableView:tableView heightForRowAtIndexPath:indexPath];
            break;
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

    if (self.event.event_id.length == 0) {
        
        [self listTicketsForNewEvent];
        
//      old when "Dingo will validate listing" alert displayed before going to homepage
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Your tickets will be listed once validated by Dingo." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert setTag:8989];
//        [alert show];
	
	} else {        // create ticket

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm dd/MM/yyyy";
        NSLog(@"Number of photo %lu", (unsigned long)[self.photos count]);
        ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
        [loadingView show];

        if (self.editTicket) {
            //Update ticket
            NSLog(@"Update");
            
            
            NSDictionary *params = @{@"ticket_id":self.ticket.ticket_id,
                                     @"price":[self.ticket.price stringValue],
                                     @"ticket_type":self.ticket.ticket_type,
                                     @"description":self.ticket.ticket_desc.length > 0 ? self.ticket.ticket_desc : @"",
                                     @"delivery_options":self.ticket.delivery_options.length > 0 ? self.ticket.delivery_options : @"",
                                     @"payment_options":self.ticket.payment_options.length > 0 ? self.ticket.payment_options : @"",
                                     @"number_of_tickets":[self.ticket.number_of_tickets stringValue],
                                     @"face_value_per_ticket":[self.ticket.face_value_per_ticket stringValue],
                                     @"ticket_type" : self.ticket.ticket_type,
                                     @"event_id": self.event.event_id
                                     };
            
            NSLog(@"params %lu", (unsigned long)[self.photos count]);
            
            [WebServiceManager updateTicket:params photos:nil completion:^(id response, NSError *error) {
                NSLog(@"PVC updateTicket response %@", response);
                
                if (response[@"id"]) {
					//upload photos one by one
					for (int i = 0; i < self.photos.count; i++) {
						DLog(@"Uploading photo #%i for ticked with id: %@", i, response[@"id"]);
						[WebServiceManager updateTicket:@{@"ticket_id":response[@"id"]}
												 photos:@[self.photos[i]]
											 completion:^(id response, NSError *error) {
												 if (!error ) {
													 if (!response[@"id"]) {
														 [AppManager showAlert:@"There was a problem uploading the photos to your listing. Please go to My Tickets to re-add :-)"];
													 }
												 } else {
													 DLog(@"photos upload error");
													 [AppManager showAlert:@"There was a problem uploading the photos to your listing. Please go to My Tickets to re-add :-)"];
												 }
											 }];
					}
					
                    [[DataManager shared] addOrUpdateTicket:response];
                    [[AppManager sharedManager] saveContext];
                    [AppManager sharedManager].draftTicket = nil;
                    
                    [loadingView hide];

                    [self.navigationController.viewControllers[0] setSelectedIndex:0];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [AppManager showAlert:@"Changes Saved!"];
                    
                    
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDingo_ticket_editTicket"];

                } else {
                    [loadingView hide];
                    [AppManager showAlert:@"Unable to save changes, Please try later"];
                }
            }];

        } else {
            //Add new ticket
            DLog(@"Create Ticket");
            
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
            
            DLog(@"param %@", params);
			
			//lets create a ticket without any photos and then lets upate it with
			[WebServiceManager createTicket:params photos:nil completion:^(id response, NSError *error) {
				if (!error ) {
					if (response[@"id"]) {
						// ticket created, now lets update it with the photos without a spinner
						[loadingView hide];
						
						//upload photos one by one
						for (int i = 0; i < self.photos.count; i++) {
							DLog(@"Uploading photo #%i for ticked with id: %@", i, response[@"id"]);
							[WebServiceManager updateTicket:@{@"ticket_id":response[@"id"]}
													 photos:@[self.photos[i]]
												 completion:^(id response, NSError *error) {
								if (!error ) {
									if (!response[@"id"]) {
										[AppManager showAlert:@"There was a problem uploading the photos to your listing. Please go to My Tickets to re-add :-)"];
									}
								} else {
									DLog(@"photos upload error");
									[AppManager showAlert:@"There was a problem uploading the photos to your listing. Please go to My Tickets to re-add :-)"];
								}
							}];
						}
						
						[AppManager sharedManager].draftTicket = nil;
						
                        //old
//						[self.navigationController.viewControllers[0] setSelectedIndex:0];
//						[self.navigationController popToRootViewControllerAnimated:YES];
//                        [AppManager showAlert:@"Tickets Listed :-)\n\nPlease turn on push notifications and check your contact info within settings so we can let you know when they have sold!"];
                        
                        
                        //new
                        SettingsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                        [self.navigationController pushViewController:viewController animated:YES];
                        [AppManager showAlert:@"Tickets Listed :-)\n\nPlease update your email and turn on push notifications so we can let you know if they sell"];
                        
                        
                        double ticketPrice = [self.ticket.price doubleValue];
                        double ticketNumber = [self.ticket.number_of_tickets doubleValue];
                        double grossSaleDouble = ticketPrice * ticketNumber;
                        double grossSaleCommissionDouble = grossSaleDouble / 10;
                        NSNumber *grossSaleNSnumber = [NSNumber numberWithDouble: grossSaleDouble];
                        NSNumber *grossSaleCommissionNSnumber = [NSNumber numberWithDouble: grossSaleCommissionDouble];
                        
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        
                        [mixpanel.people increment:@"Total tickets listed" by: self.ticket.number_of_tickets];
                        [mixpanel.people increment:@"Gross ticket value listed" by: grossSaleNSnumber];
                        
                        [[AppsFlyerTracker sharedTracker] trackEvent:@"Tickets listed commission" withValue: [NSString stringWithFormat:@"%@", grossSaleCommissionNSnumber]];
                        
                        
					} else {
						[loadingView hide];
						[AppManager showAlert:@"Unable to create ticket."];
					}
				} else {
					[loadingView hide];
					[WebServiceManager handleError:error];
					DLog(@"photos upload error ???");
				}
			}];
        }
    }
}

#pragma mark - alert view delegate

// old when "Dingo will validate listing" alert displayed before going to homepage
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (alertView.tag == 8989) {

-(void)listTicketsForNewEvent{
        
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm dd/MM/yyyy";
    NSLog(@"Number of photo %lu", (unsigned long)[self.photos count]);
  
    
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
        NSDictionary *params = @{ @"category_id" : @"",
                                  @"name" : self.event.name,
                                  @"date" : [formatter stringFromDate:self.event.date],
                                  //@"end_date" : [formatter stringFromDate:self.event.endDate],
                                  //@"address" : self.event.address.length > 0 ? self.event.address : @"",
                                  //@"city" : self.event.city.length > 0 ? self.event.city : @"",
                                  //@"postcode" : self.event.postalCode.length > 0 ? self.event.postalCode : @"",
                                  //@"location" : location,
                                  @"image" : self.event.thumb != nil ? self.event.thumb : @""
                                  
                                  
                                  };
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] initWithDictionary:params];
        
        if (!HAS_DATA(dictParam, @"category_id")) {
            [dictParam removeObjectForKey:@"category_id"];
            
            if (!HAS_DATA(dictParam, @"address")) {
                [dictParam removeObjectForKey:@"address"];
            }
            if (!HAS_DATA(dictParam, @"city")) {
                [dictParam removeObjectForKey:@"city"];
            }
            if (!HAS_DATA(dictParam, @"postcode")) {
                [dictParam removeObjectForKey:@"postcode"];
            }
            if (!HAS_DATA(dictParam, @"location")) {
                [dictParam removeObjectForKey:@"location"];
            }
            if (!HAS_DATA(dictParam, @"image")) {
                [dictParam removeObjectForKey:@"image"];
            }
        }
        
        [WebServiceManager createEvent:dictParam completion:^(id response, NSError *error) {
            NSLog(@"PVC createEvent response %@", response);
            
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
                    
					//lets create a ticket without any photos and then lets upate it with
					[WebServiceManager createTicket:params photos:nil completion:^(id response, NSError *error) {
						if (!error ) {
							if (response[@"id"]) {
								// ticket created, now lets update it with the photos without a spinner
								[loadingView hide];
								
								DLog(@"Upload photos for ticked with id: %@", response[@"id"]);
								[WebServiceManager updateTicket:@{@"ticket_id":response[@"id"]} photos:self.photos completion:^(id response, NSError *error) {
									if (!error ) {
										if (!response[@"id"]) {
											[AppManager showAlert:@"Unable to upload photos to ticket."];
										}
									} else {
										[WebServiceManager handleError:error];
									}
								}];
								
								[AppManager sharedManager].draftTicket = nil;
								
//								[self.navigationController.viewControllers[0] setSelectedIndex:0];
//								[self.navigationController popToRootViewControllerAnimated:YES];
//                                [AppManager showAlert:@"Thanks! We'll just take a quick look and list your tickets shortly :-)\n\nPlease turn on push notifications and check your contact info within settings so we can let you know when they have sold!"];
                                
                                //new
                                SettingsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                                [self.navigationController pushViewController:viewController animated:YES];
                                [AppManager showAlert:@"Your tickets will be listed once verified :-)\n\nPlease update your email and turn on push notifications so we can let you know if they sell"];
                                
                                
                                double ticketPrice = [self.ticket.price doubleValue];
                                double ticketNumber = [self.ticket.number_of_tickets doubleValue];
                                double grossSaleDouble = ticketPrice * ticketNumber;
                                double grossSaleCommissionDouble = grossSaleDouble / 10;
                                NSNumber *grossSaleNSnumber = [NSNumber numberWithDouble: grossSaleDouble];
                                NSNumber *grossSaleCommissionNSnumber = [NSNumber numberWithDouble: grossSaleCommissionDouble];

                                
                                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                
                                [mixpanel.people increment:@"Total tickets listed" by: self.ticket.number_of_tickets];
                                [mixpanel.people increment:@"Gross ticket value listed" by: grossSaleNSnumber];
                                
                                [[AppsFlyerTracker sharedTracker] trackEvent:@"Tickets listed commission" withValue: [NSString stringWithFormat:@"%@", grossSaleCommissionNSnumber]];
                                
                                
							} else {
								[loadingView hide];
								[AppManager showAlert:@"Unable to create ticket."];
							}
						} else {
							[loadingView hide];
							[WebServiceManager handleError:error];
						}
					}];
                }else{
                    [loadingView hide];
                    [WebServiceManager handleError:error];
                }
            } else {
                [loadingView hide];
                [WebServiceManager handleError:error];
            }
            
           
            
        }];
    }];
 //   }

}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark



@end
