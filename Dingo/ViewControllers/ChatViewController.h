//
//  ChatViewController.h
//  Dingo
//
//  Created by Tigran Aslanyan on 04.09.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ticket.h"

@interface ChatViewController : UIViewController

@property (nonatomic) Ticket *ticket;
@property (nonatomic) NSString *receiverName;
@property (nonatomic) NSString *receiverID;

- (void)reloadMessages;

@end
