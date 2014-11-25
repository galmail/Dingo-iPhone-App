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
#import "NewOfferViewController.h"
#import "CheckoutViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import "MutualFriendCell.h"

//static const NSUInteger photosCellIndex = 1;
static const NSUInteger commentCellIndex = 4;


@interface TicketDetailViewController () <BottomBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    BottomEditBar *bottomBar;
    
    __weak IBOutlet UILabel *lblTicketCount;
    __weak IBOutlet UILabel *lblFaceValue;
    __weak IBOutlet UILabel *lblComment;
    __weak IBOutlet UILabel *lblTicketType;
    __weak IBOutlet UILabel *lblPayment;
    __weak IBOutlet UILabel *lblDelivery;
}

//@property (nonatomic, weak) IBOutlet ProposalCell *proposalCell;
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
//@property (weak, nonatomic) IBOutlet MKMapView *locationMap;
@property (strong, nonatomic) IBOutlet UILabel *priceTicketLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceTicketLbl;
@property (strong, nonatomic) IBOutlet UICollectionView *mutualFriendCollection;
@property (strong, nonatomic) IBOutlet UILabel *mutualFriendsLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *mutualFriendCell;

@end

@implementation TicketDetailViewController{
    NSMutableArray *profileImageURL;
    NSMutableArray *names;
    NSMutableArray *currentUserFriends;
    NSMutableArray *ticketOwnerFriends;
}


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
    self.ticketsCountlabel.font = self.faceValueLabel.font = self.descriptionTextView.font =  self.paymentLabel.font =  self.ticketTypeLabel.font =  self.deliveryLabel.font = self.priceTicketLabel.font = self.priceTicketLbl.font = [DingoUISettings lightFontWithSize:14];
    
    self.contactCellerButton.titleLabel.font = self.requestToBuyButton.titleLabel.font = self.offerPriceButton.titleLabel.font = [DingoUISettings lightFontWithSize:16];
    
    [[self.requestToBuyButton layer] setBorderWidth:4];
    [[self.requestToBuyButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
    
    self.sellerNameLabel.font = [DingoUISettings fontWithSize:19];
 
    [self.mutualFriendCell setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.ticket = [[DataManager shared] ticketByID:self.ticket.ticket_id];
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
    self.faceValueLabel.text = [NSString stringWithFormat:@"£%@",[self.ticket.face_value_per_ticket stringValue]];
    self.descriptionTextView.text = self.ticket.ticket_desc;
    self.paymentLabel.text = self.ticket.payment_options;
    self.ticketTypeLabel.text = self.ticket.ticket_type;
    self.deliveryLabel.text = self.ticket.delivery_options;
    self.priceTicketLabel.text = [NSString stringWithFormat:@"£%@",[self.ticket.price stringValue]];
    self.sellerNameLabel.text = self.ticket.user_name;
    self.sellerImageView.image = [UIImage imageWithData:self.ticket.user_photo];
        
    
    profileImageURL = [[NSMutableArray alloc] init];
    names = [[NSMutableArray alloc] init];
    currentUserFriends = [[NSMutableArray alloc] init];
    ticketOwnerFriends = [[NSMutableArray alloc] init];

    [profileImageURL addObject:@"mutual-friend.png"];
    [names addObject:@""];
    

    if ([[AppManager sharedManager].userInfo[@"fb_id"] length] > 0){

        [FBSession openActiveSessionWithReadPermissions:@[@"user_friends",@"public_profile",@"email"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          
                                          if (error) {
                                              [AppManager showAlert:[error localizedDescription]];
                                              
                                          } else {
                                              if (state == FBSessionStateOpen) {
                                                  
                                                  [self getCurrentUserFriends];

                                              }
                                          }
                                      }];
    }
    
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

- (void)getCurrentUserFriends{
    
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              
                              if (result != nil) {
//                                  NSLog(@"result %@", result);
                                  
                                  if ([result isKindOfClass:[NSDictionary class]]) {
                                      NSDictionary *dict = result;
                                      
                                      NSArray *friends = [dict objectForKey:@"data"];
                                      
                                      for (NSDictionary *dict in friends) {
                                          [currentUserFriends addObject:dict];
                                      }
                                      
                                      [self getTicketOwnerFriends];
                                  }
                              }
                          }];
    
}

- (void)getTicketOwnerFriends{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/friends", self.ticket.facebook_id]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              
                              if (result != nil) {
//                                  NSLog(@"result %@", result);
                                  
                                  if ([result isKindOfClass:[NSDictionary class]]) {
                                      NSDictionary *dict = result;
                                      
                                      NSArray *friends = [dict objectForKey:@"data"];
                                      
                                      for (NSDictionary *dict in friends) {
                                          [ticketOwnerFriends addObject:dict];
                                      }
                                      
                                      [self getMutualFriend];
                                  }
                              }
                          }];
}

- (void)getMutualFriend {
    
    for (NSDictionary *currentFriends in currentUserFriends) {
        for (NSDictionary *ownerFriends in ticketOwnerFriends) {
            if ([[currentFriends objectForKey:@"id"] isEqualToString:[ownerFriends objectForKey:@"id"]]) {
                NSString *name = [currentFriends objectForKey:@"name"];
                NSArray *temp = [name componentsSeparatedByString:@" "];
                [names addObject:[temp objectAtIndex:0]];
                [profileImageURL addObject:[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200", [currentFriends objectForKey:@"id"]]];
            }
        }
    }
    
//    NSLog(@"test %@ %@", names, profileImageURL);
    [self.mutualFriendCell setHidden:NO];
    CGRect frameCell = self.mutualFriendCell.frame;
    [self.mutualFriendCell setFrame:CGRectMake(frameCell.origin.x, frameCell.origin.y, frameCell.size.width, 140)];
    [self.mutualFriendCollection reloadData];
    [self.mutualFriendsLabel setText:[NSString stringWithFormat:@"Mutual friends (%lu)", [profileImageURL count] -1]];
}

- (void) makeRequestForUserData
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
        } else {
            // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
            NSLog(@"error %@", error.description);
        }
    }];
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
        case commentCellIndex: {
            CGSize size = [self.descriptionTextView sizeThatFits:CGSizeMake(self.descriptionTextView.frame.size.width, FLT_MAX)];
            if (self.descriptionTextView.text.length == 0) {
                return 36;
            } else {
                CGRect frame = self.descriptionTextView.frame;
                frame.size.height = size.height;
                self.descriptionTextView.frame = frame;
                return size.height;
            }
            
            break;
        }
        case 8:{
            if ([self.photosPreviewCell.photos count] == 0) {
                return 0;
            } else {
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        }
        case 10:{
            if (self.mutualFriendCell.isHidden) {
                return 0;
            } else {
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
            break;
        }
    }
    
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - BottomBarDelegate

- (void)editListing {
    [self performSegueWithIdentifier:@"EditTicket" sender:self];
}

- (void)deleteListing {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Listing?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 1 ) {
        if (buttonIndex == 1) {
            NSDictionary *params = @{@"ticket_id":self.ticket.ticket_id,
                                     @"price":[self.ticket.price stringValue],
                                     @"available":@"0"
                                     };
            
            [WebServiceManager updateTicket:params photos:nil completion:^(id response, NSError *error) {
                NSLog(@"response %@", response);
                
                if (!error && [response[@"available"] intValue] == 0) {
                    [[AppManager sharedManager].managedObjectContext deleteObject:self.ticket];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }];
        }
    }
    
    if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            [WebServiceManager signInWithFBAndUpdate:YES completion:^(id response, NSError *error) {
                if (response) {
                    ChatViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                    viewController.ticket = self.ticket;
                    viewController.receiverName = self.ticket.user_name;
                    viewController.receiverID = [self.ticket.user_id stringValue];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                [loadingView hide];
            }];
        }
    }
    
    if (alertView.tag == 12) {
        if (buttonIndex == 1) {
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            [WebServiceManager signInWithFBAndUpdate:YES completion:^(id response, NSError *error) {
                if (response) {
                    CheckoutViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckoutViewController"];
                    viewController.ticket = self.ticket;
                    viewController.event = self.event;
                    [self.navigationController pushViewController:viewController animated:YES];

                }
                [loadingView hide];
            }];
        }
    }
    
    if (alertView.tag == 13) {
        if (buttonIndex == 1) {
            
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            [WebServiceManager signInWithFBAndUpdate:YES completion:^(id response, NSError *error) {
                if (response) {
                    NewOfferViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewOfferViewController"];
                    viewController.ticket = self.ticket;
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                
                [loadingView hide];
            }];
        }
    }
    
    
}

#pragma mark Actions

- (IBAction)contactSeller:(id)sender {
    
    
    if (![[[AppManager sharedManager].userInfo valueForKey:@"fb_id"] length]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log in via Facebook?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 11;
        [alert show];
        
    } else {
        ChatViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        viewController.ticket = self.ticket;
        viewController.receiverName = self.ticket.user_name;
        viewController.receiverID = [self.ticket.user_id stringValue];
        [self.navigationController pushViewController:viewController animated:YES];

    }
    
}

- (IBAction)requestToBuy:(id)sender {
    
    if (![[[AppManager sharedManager].userInfo valueForKey:@"fb_id"] length]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log in via Facebook?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 12;
        [alert show];
        
    } else {
        CheckoutViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckoutViewController"];
        viewController.ticket = self.ticket;
        viewController.event = self.event;
        [self.navigationController pushViewController:viewController animated:YES];

    }

}

- (IBAction)offerNewPrice:(id)sender {
    
    if (![[[AppManager sharedManager].userInfo valueForKey:@"fb_id"] length]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log in via Facebook?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 13;
        [alert show];
        
    } else {
        NewOfferViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewOfferViewController"];
        viewController.ticket = self.ticket;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"EditTicket"]) {
        ListTicketsViewController *viewController = (ListTicketsViewController *)segue.destinationViewController;
        viewController.ticket = self.ticket;
        viewController.event = self.event;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDingo_ticket_editTicket"];
        [[NSUserDefaults standardUserDefaults] setObject:self.ticket.ticket_id forKey:@"kDingo_ticket_ticket_id"];
        [[NSUserDefaults standardUserDefaults] setObject:self.event.event_id forKey:@"kDingo_event_event_id"];
        [[NSUserDefaults standardUserDefaults] setObject:self.event.category_id forKey:@"kDingo_event_categoryID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [profileImageURL count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(72, 90);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [collectionView registerNib:[UINib nibWithNibName:@"MutualFriendCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MutualFriendCell"];
    MutualFriendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MutualFriendCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        [cell.profileImage setImage:[UIImage imageNamed:[profileImageURL objectAtIndex:indexPath.row]]];
    } else {
        NSURL *imageURL = [NSURL URLWithString:[profileImageURL objectAtIndex:indexPath.row]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        [cell.profileImage setImage:[UIImage imageWithData:imageData]];
    }
    
    [cell.nameLabel setText:[names objectAtIndex:indexPath.row]];
    
    return cell;
}


@end
