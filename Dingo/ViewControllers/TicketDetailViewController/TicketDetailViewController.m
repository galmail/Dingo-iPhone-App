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
#import "WebServiceManager.h"
#import <MessageUI/MessageUI.h>

#import "NSString+DingoFormatting.h"

#import <FacebookSDK/FacebookSDK.h>
#import "MutualFriendCell.h"

//static const NSUInteger photosCellIndex = 1;
static const NSUInteger commentCellIndex = 5;


@interface TicketDetailViewController () <BottomBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate,MFMailComposeViewControllerDelegate> {
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
@synthesize iseditable;

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
    
    if ([[self.ticket.number_of_tickets stringValue] isEqual: @"0"]) {
        self.ticketsCountlabel.text = [self.ticket.number_of_tickets_sold stringValue];
    } else {
        self.ticketsCountlabel.text = [self.ticket.number_of_tickets stringValue];
    }
	
	//old
	//self.faceValueLabel.text = [NSString stringWithFormat:@"£%@",[self.ticket.face_value_per_ticket stringValue]];
	//new
	self.faceValueLabel.text = [NSString stringWithFormat:@"£%@",[NSString stringWithCurrencyFormattingForPrice:self.ticket.face_value_per_ticket]];
	
    self.descriptionTextView.text = self.ticket.ticket_desc;
	NSLog(@"ticket_desc: %@", self.ticket.ticket_desc);
	
	
    self.paymentLabel.text = self.ticket.payment_options;
    self.ticketTypeLabel.text = self.ticket.ticket_type;
    self.deliveryLabel.text = self.ticket.delivery_options;
	
	//old
	//self.priceTicketLabel.text = [NSString stringWithFormat:@"£%@",[self.ticket.price stringValue]];
	//new
	self.priceTicketLabel.text = [NSString stringWithFormat:@"£%@",[NSString stringWithCurrencyFormattingForPrice:self.ticket.price]];
	
	self.sellerNameLabel.text = self.ticket.user_name;
    self.sellerImageView.image = [UIImage imageWithData:self.ticket.user_photo];
        
    
    profileImageURL = [[NSMutableArray alloc] init];
    names = [[NSMutableArray alloc] init];
    currentUserFriends = [[NSMutableArray alloc] init];
    ticketOwnerFriends = [[NSMutableArray alloc] init];

    [profileImageURL addObject:@"mutual-friend.png"];
    [names addObject:@""];
    

	// as requested by phil i am disabling the fb calls for now, hence this if (NO)
	if (NO){	//([[AppManager sharedManager].userInfo[@"fb_id"] length] > 0){
		
		DLog(@">>>>>> fb_id: %@", [AppManager sharedManager].userInfo[@"fb_id"]);
		DLog(@">>>>> will open active fb session");
		
        [FBSession openActiveSessionWithReadPermissions:@[@"user_friends",@"public_profile",@"email"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          
                                          if (error) {
                                              [AppManager showAlert:[error localizedDescription]];
                                              
                                          } else {
											  //DLog(@">>>>> state: %i", state);
                                              if (state == FBSessionStateOpen) {
												  
												  DLog(@">>>>> get fb friends");
                                                  [self getCurrentUserFriends];

											  } else DLog(@">>>>> dont get fb friends");
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
        if (!self.event)
            [bottomBar.editButton setHidden:YES];
        if (iseditable)
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
	DLog();
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
								  DLog(@"result %@", result);
                                  
                                  if ([result isKindOfClass:[NSDictionary class]]) {
                                      NSDictionary *dict = result;
                                      
                                      NSArray *friends = [dict objectForKey:@"data"];
                                      
                                      for (NSDictionary *dict in friends) {
                                          [currentUserFriends addObject:dict];
                                      }
                                      
                                      [self getTicketOwnerFriends];
                                  }
							  } else DLog(@"error: %@", error.localizedDescription);
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
    [self.mutualFriendsLabel setText:[NSString stringWithFormat:@"Mutual friends (%lu)", (unsigned long)[profileImageURL count] -1]];
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
                return size.height + 36;
            }
            
            break;
        }
        case 7:{
            if ([self.photosPreviewCell.photos count] == 0) {
                return 0;
            } else {
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        }
        case 11:{
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
    if (self.event) {
        [self performSegueWithIdentifier:@"EditTicket" sender:self];
    }
    
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
                NSLog(@"TDVC response %@", response);
                
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Please login to Facebook to contact other users." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Please login to Facebook to buy tickets." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Please login to Facebook to buy tickets." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
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
    
    NSString *text = [NSString stringWithFormat:@"Hey, check out these tickets to %@. You can find them on Dingo, download the app here %@" , self.event.name, @"www.dingoapp.co.uk." ];
   
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        
        NSString *shareType = @"I shared a listing";

        if ([activityType isEqualToString: UIActivityTypeMail])  {
            shareType = @"I shared a listing by email";
        }
        if ([activityType isEqualToString: UIActivityTypeMessage])  {
            shareType = @"I shared a listing by text";
        }
        if ([activityType isEqualToString: UIActivityTypePostToTwitter])  {
            shareType = @"I shared a listing by twitter";
        }
        if ([activityType isEqualToString: UIActivityTypePostToFacebook])  {
            shareType = @"I shared a listing by FB";
        }
        
        if(completed){
        NSDictionary *params = @{@"receiver_id" : @"32", @"content" : shareType, @"visible" : @"false", @"ticket_id": self.ticket.ticket_id};
            [WebServiceManager sendMessage:params completion:^(id response, NSError *error) {}];
        }
        
    }];
    
    [self presentViewController:activityController animated:YES completion:nil];
}


#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)reportListing:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail sending not available");
        return;
    }
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:@[@"report@dingoapp.co.uk"]];
    [mailComposer setSubject:@"Report Listing"];
    [mailComposer setMessageBody:[NSString stringWithFormat:@"I would like to report this listing (#%@) because:\n", self.ticket.ticket_id]
                          isHTML:YES];
    mailComposer.mailComposeDelegate = self;
    [self presentViewController:mailComposer animated:YES completion:nil];
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
