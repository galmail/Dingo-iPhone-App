//
//  ChatViewController.m
//  Dingo
//
//  Created by Tigran Aslanyan on 04.09.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ChatViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "DingoField.h"
#import "WebServiceManager.h"
#import "ZSLoadingView.h"
#import "DataManager.h"
#import "ZSLabel.h"
#import "TicketDetailViewController.h"
#import <MessageUI/MessageUI.h>

@interface ChatViewController ()<UIBubbleTableViewDataSource, ZSLabelDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    IBOutlet DingoField *textField;
	IBOutlet UIBarButtonItem *actionsButton;
    NSMutableArray *bubbleData;
    BOOL fromDingo;
    
    UIRefreshControl *refreshControl;
}

@end

@implementation ChatViewController
@synthesize messageData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    [bubbleTable addSubview:refreshControl];

    
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textField.font = [DingoUISettings fontWithSize:textField.font.pointSize];
    
    bubbleData = [NSMutableArray new];
    bubbleTable.snapInterval = 120;
    bubbleTable.bubbleDataSource = self;
    
    bubbleTable.showAvatars = YES;
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    [bubbleTable reloadData];
    [bubbleTable scrollBubbleViewToBottomAnimated:YES];
   
    // Keyboard events
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    //************adding observer for messages********************
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived) name:@"messageReceived" object:nil];
    
    //============================================================
   
	self.title = self.receiverName;
	
	//we dont need to fetch messages as they are already loaded ;)
//    [self reloadMessagesWithCompletion:^(BOOL finished) {
//        [bubbleTable reloadData];
//        [bubbleTable scrollBubbleViewToBottomAnimated:NO];
//    }];

	//DLog(@"bubbleData: %@", bubbleData);
	//we only do this when bubbleData is empty
	if (bubbleData.count == 0) {
		[self performSelector:@selector(reloadMessages) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
	}
	
	//another way
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		[self reloadMessages];
//	});
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark -


-(void)messageReceived{
    [self reloadMessages];

}

-(void)refreshInvoked:(id)sender forState:(UIControlState)state {
    
    [refreshControl beginRefreshing];
    
    [self reloadMessagesWithCompletion:^(BOOL finished) {
        [refreshControl endRefreshing];
    }];
    
}


- (void)reloadMessagesWithCompletion:( void (^) (BOOL finished)) handler {
    
    [[DataManager shared] fetchMessagesWithCompletion:^(BOOL finished) {
        [self reloadMessages];
               if (handler) {
            handler(YES);
        }
        
    }];
    
}

-(void)reloadMessages{
    NSNumber *userID = [AppManager sharedManager].userInfo[@"id"] ;
    NSArray * messages=nil;
    NSString *coversationId=@"";
    if(!messageData){
        if (!self.ticket) {
            int user=[userID intValue];
            int otheruser=[self.receiverID intValue];
            coversationId=[NSString stringWithFormat:@"-%d-%d",MIN(user, otheruser),MAX(user, otheruser)];
        }else{
            int user=[userID intValue];
            int otheruser=[self.receiverID intValue];
            if (otheruser<=0)
                otheruser=[self.ticket.user_id intValue];
            
            coversationId=[NSString stringWithFormat:@"%@-%d-%d",self.ticket.ticket_id, MIN(user, otheruser),MAX(user, otheruser)];
        }
    }
    
    
    messages  = [[DataManager shared] allMessagesForConversatinID:[AppManager sharedManager].userInfo[@"id"] conersationId:(messageData.conversation_id != nil?messageData.conversation_id:coversationId)];
    
    [bubbleData removeAllObjects];
	
    for (Message * msg in messages) {
        NSBubbleData *bubble = nil;
        
        
        if ([msg.from_dingo boolValue] ) {
            
            if ([msg.offer_new boolValue] && [msg.receiver_id isEqualToString:[[AppManager sharedManager].userInfo[@"id"] stringValue]]) {
                NSString * offerText = [NSString stringWithFormat:@"<font face='SourceSansPro-Regular' size=14 color='#ffffff'>%@ <a href='accept_%@'>Accept</a> or <a href='reject_%@'>Reject</a> </font>", msg.content, msg.offer_id, msg.offer_id];
                bubble = [NSBubbleData dataWithText:offerText date:msg.datetime type:BubbleTypeDingo delegate:self];
            } else {
                bubble = [NSBubbleData dataWithText:msg.content date:msg.datetime type:BubbleTypeDingo];
            }
            
            if (msg.sender_avatar_url.length>0) {
                if (msg.sender_avatar) {
                    bubble.avatar = [UIImage imageWithData:msg.sender_avatar];
                }else{
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:msg.sender_avatar_url]];
                    msg.sender_avatar = imageData;
                    [msg.managedObjectContext save:nil];
                    bubble.avatar = [UIImage imageWithData:msg.sender_avatar];
                }
            }
        } else {
            
            if ([msg.sender_id isEqualToString:[[[AppManager sharedManager].userInfo valueForKey:@"id"] stringValue]]) {
                bubble = [NSBubbleData dataWithText:msg.content date:msg.datetime type:BubbleTypeMine];
                
                NSString *user_photo_url = [AppManager sharedManager].userInfo[@"photo_url"];
                NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_photo_url]];
                
                bubble.avatar = [UIImage imageWithData:data];
            }else {
                bubble = [NSBubbleData dataWithText:msg.content date:msg.datetime type:BubbleTypeSomeoneElse];
                if (msg.sender_avatar_url.length>0) {
                    if (msg.sender_avatar) {
                        bubble.avatar = [UIImage imageWithData:msg.sender_avatar];
                    }else{
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:msg.sender_avatar_url]];
                        msg.sender_avatar = imageData;
                        [msg.managedObjectContext save:nil];
                        bubble.avatar = [UIImage imageWithData:msg.sender_avatar];
                    }
                }
            }
            
        }
        
        [bubbleData addObject:bubble];
		
		
		DLog(@"msg.read: %i", msg.read.boolValue);
		DLog(@"msg.sender_id: %@", msg.sender_id);
		DLog(@"userID.stringValue: %@", userID.stringValue);
		
		//mark as read, we only want this to happen when image is not set as ready yet
        if (![msg.sender_id isEqual:[userID stringValue]] && !msg.read.boolValue) {
            [WebServiceManager markAsRead:@{@"messageID":msg.message_id} completion:^(id response, NSError *error) {
                if (response) {
                    [[DataManager shared] addOrUpdateMessage:response];
                }
            }];
        }
        
    }
	
	[self updateActionsButton];
    
    [bubbleTable reloadData];
    [bubbleTable scrollBubbleViewToBottomAnimated:YES];
}

- (void)updateActionsButton {
	if (self.ticket && self.navigationItem.rightBarButtonItem == nil && [bubbleData count] > 0){
		self.navigationItem.rightBarButtonItem = actionsButton;
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}

#pragma mark -

//convenience setter
- (void)setTicket:(Ticket *)ticket {
	if (ticket != _ticket) {
		_ticket = ticket;
		[self updateActionsButton];
	}
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actions:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Listing", @"Report User", nil];
    
    [actionSheet showInView:self.view];
    [self changeTextColorForUIActionSheet:actionSheet];
}

- (void) changeTextColorForUIActionSheet:(UIActionSheet*)actionSheet {
    UIColor *tintColor = [DingoUISettings backgroundColor];
    
    NSArray *actionSheetButtons = actionSheet.subviews;
    for (int i = 0; [actionSheetButtons count] > i; i++) {
        UIView *view = (UIView*)[actionSheetButtons objectAtIndex:i];
        if([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton*)view;
            
//            if ([btn.titleLabel.text isEqual:@"Cancel"]) {
//                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                [btn setBackgroundColor:tintColor];
//            } else {
                [btn setTitleColor:tintColor forState:UIControlStateNormal];
//            }
            
        }
    }
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    NSLog(@"count %lu", (unsigned long)[bubbleData count]);
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
	DLog();
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		
        CGRect frame = textInputView.frame;
        CGFloat topOfTheKeyboard = self.view.frame.size.height - kbSize.height - frame.size.height;
		frame.origin.y = topOfTheKeyboard;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height = topOfTheKeyboard;
        bubbleTable.frame = frame;
        [bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	DLog();
	NSDictionary* info = [aNotification userInfo];
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		
        CGRect frame = textInputView.frame;
		CGFloat bottomOfTheScreen = self.view.frame.size.height - frame.size.height;
        frame.origin.y = bottomOfTheScreen;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height = bottomOfTheScreen;
        bubbleTable.frame = frame;
    }];
}


-(BOOL)textFieldShouldReturn:(UITextField *)txtField{
    [txtField resignFirstResponder];
    return NO;
}

#pragma mark - Actions

- (IBAction)btnSendTap:(id)sender
{
    if ([[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] length]  == 0) {
        return;
    }
     NSString *ticketID=@"";
    if (messageData.ticket_id !=nil) {
        ticketID=messageData.ticket_id;
    }
   
    NSDictionary *params = @{ @"ticket_id": self.ticket.ticket_id==nil?ticketID:self.ticket.ticket_id, @"receiver_id" : self.receiverID, @"content" : textField.text };
    
    [WebServiceManager sendMessage:params completion:^(id response, NSError *error) {
        if (!error) {
			NSLog(@"CHAT response: %@", response);
            if (response[@"id"]) {
                [[DataManager shared] addOrUpdateMessage:response];
                
                NSBubbleData *bubble = [NSBubbleData dataWithText:response[@"content"] date:[NSDate date] type:BubbleTypeMine];
                
                NSString *user_photo_url = [AppManager sharedManager].userInfo[@"photo_url"];
                NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_photo_url]];
                
                bubble.avatar = [UIImage imageWithData:data];
                [bubbleData addObject:bubble];
                
                [bubbleTable reloadData];
                [bubbleTable scrollBubbleViewToBottomAnimated:YES];
                
            }
        }
    }];
    
    textField.text = @"";
    //[textField resignFirstResponder];
}

#pragma mark ZSLabelDelegate methods

- (void)ZSLabel:(id)ZSLabel didSelectLinkWithURL:(NSURL*)url {
    NSString * action = [url absoluteString];
    
    NSArray *offerArray = [action componentsSeparatedByString:@"_"];
    if (offerArray.count == 2) {
        NSString *offerID = offerArray[1];
        NSString *offerAction = offerArray[0];

        if ([offerAction isEqualToString:@"accept"]) {
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            [WebServiceManager replyOffer:@{@"accept_offer": @"1", @"offerID":offerID} completion:^(id response, NSError *error) {
                [loadingView hide];
                
                if (response) {
                    [self reloadMessagesWithCompletion:nil];
                }else{
                    [WebServiceManager handleError:error];
                }
                
            }];
        }
        
        if ([offerAction isEqualToString:@"reject"]) {
            ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Please wait..."];
            [loadingView show];
            [WebServiceManager replyOffer:@{@"accept_offer": @"0", @"offerID":offerID} completion:^(id response, NSError *error) {
                [loadingView hide];
                if (response) {
                    [self reloadMessagesWithCompletion:nil];
                }else{
                    [WebServiceManager handleError:error];
                }
                
            }];
        }
    }
    
   
}


#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        // View Listing
        
        TicketDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailViewController"];
        viewController.event = [[DataManager shared] eventByID:self.ticket.event_id];
        viewController.ticket = self.ticket;
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    
    if (buttonIndex == 1) {
        // Report User

        if (![MFMailComposeViewController canSendMail]) {
            NSLog(@"Mail sending not available");
            return;
        }
        
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setToRecipients:@[@"report@dingoapp.co.uk"]];
        [mailComposer setMessageBody:@""
                              isHTML:YES];
        mailComposer.mailComposeDelegate = self;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }

}

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
