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

@interface ChatViewController ()<UIBubbleTableViewDataSource>{
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    
    IBOutlet DingoField *textField;
    
    NSMutableArray *bubbleData;
}

@end

@implementation ChatViewController

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
    
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textField.font = [DingoUISettings fontWithSize:textField.font.pointSize];
    
    bubbleData = [NSMutableArray new];
    bubbleTable.snapInterval = 120;
    bubbleTable.bubbleDataSource = self;
    
    bubbleTable.showAvatars = YES;
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    [bubbleTable reloadData];
    
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    
    ZSLoadingView *loadingView = [[ZSLoadingView alloc] initWithLabel:@"Loading..."];
    [loadingView show];
    [[DataManager shared] fetchMessagesWithCompletion:^(BOOL finished) {
        
        [loadingView hide];
        NSArray * messages = [[DataManager shared] allMessagesWith:self.ticket.user_id ticketID:self.ticket.ticket_id];
        
        
        for (Message * msg in messages) {
            NSBubbleData *bubble = nil;
            NSLog(@"%@",[AppManager sharedManager].userInfo);
            if ([msg.sender_id isEqualToString:[[[AppManager sharedManager].userInfo valueForKey:@"id"] stringValue]]) {
                bubble = [NSBubbleData dataWithText:msg.content date:msg.datetime type:BubbleTypeMine];
                
                NSString *user_photo_url = [AppManager sharedManager].userInfo[@"photo_url"];
                NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_photo_url]];

                bubble.avatar = [UIImage imageWithData:data];
            }else{
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
            
            [bubbleData addObject:bubble];
        }
        
        [bubbleTable reloadData];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}


//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}

#pragma mark - Actions

- (IBAction)btnSendTap:(id)sender
{
    
    if (textField.text.length == 0) {
        return;
    }
    
    NSDictionary *params = @{ @"ticket_id": self.ticket.ticket_id, @"receiver_id" : self.ticket.user_id, @"content" : textField.text };
    
    [WebServiceManager sendMessage:params completion:^(id response, NSError *error) {
        if (!error) {
            if (response[@"id"]) {
                [[DataManager shared] addOrUpdateMessage:response];
                
                NSBubbleData *bubble = [NSBubbleData dataWithText:response[@"content"] date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeMine];
                
                NSString *user_photo_url = [AppManager sharedManager].userInfo[@"photo_url"];
                NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_photo_url]];
                
                bubble.avatar = [UIImage imageWithData:data];
                [bubbleData addObject:bubble];
                
                [bubbleTable reloadData];
                
            }
        }
    }];
    
    textField.text = @"";
    [textField resignFirstResponder];
}
@end
