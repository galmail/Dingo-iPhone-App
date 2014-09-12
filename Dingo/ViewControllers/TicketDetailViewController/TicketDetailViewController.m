//
//  TicketDetailViewController.m
//  Dingo
//
//  Created by Asatur Galstyan on 8/15/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "ListTicketsViewController.h"
#import "ProposalCell.h"
#import "PhotosPreviewCell.h"
#import "WebServiceManager.h"
#import "ZSLoadingView.h"
#import "AppManager.h"
#import <MapKit/MapKit.h>
#import "DataManager.h"
#import <Social/Social.h>
#import "BottomEditBar.h"
#import "ChatViewController.h"
#import "MapViewController.h"
#import "ImagesViewController.h"

static const NSUInteger photosCellIndex = 1;
static const NSUInteger commentCellIndex = 4;


@interface TicketDetailViewController () <BottomBarDelegate> {
    BottomEditBar *bottomBar;
    
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
@property (nonatomic, weak) IBOutlet UIButton *offerPriceButton;
@property (nonatomic, weak) IBOutlet UIImageView *sellerImageView;
@property (nonatomic, weak) IBOutlet UILabel *sellerNameLabel;
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

    lblTicketCount.font = lblFaceValue.font = lblComment.font = lblTicketType.font = lblPayment.font = lblDelivery.font = [DingoUISettings lightFontWithSize:14];
    self.ticketsCountlabel.font = self.faceValueLabel.font = self.descriptionTextView.font =  self.paymentLabel.font =  self.ticketTypeLabel.font =  self.deliveryLabel.font = [DingoUISettings lightFontWithSize:14];
    
    self.contactCellerButton.titleLabel.font = self.requestToBuyButton.titleLabel.font = self.offerPriceButton.titleLabel.font = [DingoUISettings lightFontWithSize:16];
    
    self.sellerNameLabel.font = [DingoUISettings fontWithSize:19];
    
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
    self.photosPreviewCell.parentViewController = self;
    
    self.ticketsCountlabel.text = [self.ticket.number_of_tickets stringValue];
    self.faceValueLabel.text = [self.ticket.face_value_per_ticket stringValue];
    self.descriptionTextView.text = self.ticket.ticket_desc;
    self.paymentLabel.text = self.ticket.payment_options;
    self.ticketTypeLabel.text = self.ticket.ticket_type;
    self.deliveryLabel.text = self.ticket.delivery_options;
    
    [self.proposalCell buildWithData:self.event];
    
    self.sellerNameLabel.text = self.ticket.user_name;
    self.sellerImageView.image = [UIImage imageWithData:self.ticket.user_photo];
    
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
   

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.ticket.user_id isEqual:[AppManager sharedManager].userInfo[@"id"]]) {
        
        bottomBar = [[BottomEditBar alloc] initWithFrame:CGRectMake(0, 0, 360, 65)];
        bottomBar.backgroundColor = [UIColor redColor];
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        frame.origin.y = frame.origin.y + frame.size.height - bottomBar.frame.size.height;
        frame.size.height = bottomBar.frame.size.height;
        frame.size.width = 320;
        bottomBar.frame = frame;
        
        bottomBar.delegate = self;
       
        [self.navigationController.view  addSubview:bottomBar];
        
        self.contactCellerButton.enabled = self.requestToBuyButton.enabled = self.offerPriceButton.enabled = NO;
        
        CGSize contentSize = self.tableView.contentSize;
        contentSize.height += bottomBar.frame.size.height;
        self.tableView.contentSize = contentSize;
        
    } else {
        self.contactCellerButton.enabled = self.requestToBuyButton.enabled = self.offerPriceButton.enabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (bottomBar) {
        [bottomBar removeFromSuperview];
    }
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

#pragma mark - BottomBarDelegate

- (void)editListing {
//    ListTicketsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListTicketsViewController"];
//    [self.navigationController pushViewController:viewController animated:YES];
//    
//    [viewController setTicket:self.ticket event:self.event];
    
    
    [self performSegueWithIdentifier:@"EditTicket" sender:self];
}

- (void)viewOffers {
     [self performSegueWithIdentifier:@"OffersSegue" sender:self];
}

#pragma mark Actions

- (IBAction)contactSeller:(id)sender {
    ChatViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];

    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)requestToBuy:(id)sender {
    
    NSDictionary *params = @{@"ticket_id":self.ticket.ticket_id,
                             @"receiver_id": self.ticket.user_id,
                             @"num_tickets" :@"1",
                             @"price":self.ticket.price
                             };
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
    [loadingView show];
    [WebServiceManager sendOffer:params completion:^(id response, NSError *error) {
        [loadingView hide];
        
        if (!error) {
            if (response[@"id"]) {
                [AppManager showAlert:@"Offer Sent!"];
            }
            
        } else {
            [AppManager showAlert:[error localizedDescription]];
        }

    }];
    
}

- (IBAction)offerNewPrice:(id)sender {
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"EditTicket"]) {
        ListTicketsViewController *viewController = (ListTicketsViewController *)segue.destinationViewController;
        viewController.ticket = self.ticket;
        viewController.event = self.event;
    }
    
    if ([segue.identifier isEqual:@"MapSegue"]) {
        
        UINavigationController *navController = segue.destinationViewController;
        MapViewController *vc = navController.viewControllers[0];
        vc.event = self.event;
       
    }
    
    if ([segue.identifier isEqual:@"ImagesSegue"]) {
        
        UINavigationController *navController = segue.destinationViewController;
        ImagesViewController *vc = navController.viewControllers[0];
        vc.photos = self.photosPreviewCell.photos;
        
    }
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)share:(id)sender {
    
    NSString *text = [NSString stringWithFormat:@"I am selling tickets to %@, check out Dingo app if you're interested in buying %@" , self.event.name, @"http://dingoapp.co.uk" ];
   
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
