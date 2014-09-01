//
//  ListTicketsViewController.h
//  Dingo
//
//  Created by logan on 6/3/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "Ticket.h"
#import "Event.h"

@interface ListTicketsViewController : UITableViewController

@property (nonatomic) BOOL changed;

- (void)saveDraft;
- (void)setTicket:(Ticket*)_ticket event:(Event*)_event;

@end
