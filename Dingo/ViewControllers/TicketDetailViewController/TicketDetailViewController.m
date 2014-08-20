//
//  TicketDetailViewController.m
//  Dingo
//
//  Created by Asatur Galstyan on 8/15/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "ProposalCell.h"
#import "PhotosPreviewCell.h"
#import "WebServiceManager.h"
#import "ZSLoadingView.h"
#import "AppManager.h"
#import <MapKit/MapKit.h>
#import "DataManager.h"

static const NSUInteger photosCellIndex = 1;


@interface TicketDetailViewController ()

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
@property (weak, nonatomic) IBOutlet MKMapView *locationMap;

@end

@implementation TicketDetailViewController


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *photos = [NSMutableArray new];
    if (self.ticket.photo1) {
        [photos addObject:[UIImage imageWithData:self.ticket.photo1]];
    }

    if (self.ticket.photo2) {
        [photos addObject:[UIImage imageWithData:self.ticket.photo2]];
    }
    
    if (self.ticket.photo3) {
        [photos addObject:[UIImage imageWithData:self.ticket.photo3]];
    }

    self.photosPreviewCell.photos = photos;
    
    self.ticketsCountlabel.text = [self.ticket.number_of_tickets stringValue];
    self.faceValueLabel.text = [self.ticket.face_value_per_ticket stringValue];
    self.descriptionTextView.text = self.ticket.ticket_desc;
    self.paymentLabel.text = self.ticket.payment_options;
    self.ticketTypeLabel.text = self.ticket.ticket_type;
    self.deliveryLabel.text = self.ticket.delivery_options;
    
    [self.proposalCell buildWithData:self.event];
    
    self.sellerNameLabel.text = self.ticket.user_name;
    self.sellerInfolabel.text = @"";
    self.sellerImageView.image = [UIImage imageWithData:self.ticket.user_photo];
    
    [WebServiceManager addressToLocation:[DataManager eventLocation:self.event] completion:^(id response, NSError *error) {
        
        if ([response[@"status"] isEqualToString:@"OK"]) {
            NSArray *results = response[@"results"];
            if (results.count > 0) {
                NSDictionary *result = results[0];
               
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([result[@"geometry"][@"location"][@"lat"] doubleValue], [result[@"geometry"][@"location"][@"lng"] doubleValue]);
                MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
                MKCoordinateRegion region = {coord, span};
                [self.locationMap setRegion:region];
            }
            
        }
    }];
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


#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)share:(id)sender {
}

@end
