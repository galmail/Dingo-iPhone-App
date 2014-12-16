//
//  ListTicketsViewController.h
//  Dingo
//
//  Created by logan on 6/3/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "Ticket.h"
#import "Event.h"

@interface ListTicketsViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic) BOOL changed;
@property (nonatomic, strong) Ticket *ticket;
@property (nonatomic, strong) Event *event;

- (void)saveDraft;
- (void)setTicket:(Ticket*)_ticket event:(Event*)_event;

@end
