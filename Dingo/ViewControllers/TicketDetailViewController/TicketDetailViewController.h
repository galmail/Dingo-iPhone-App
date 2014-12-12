//
//  TicketDetailViewController.h
//  Dingo
//
//  Created by Asatur Galstyan on 8/15/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ticket.h"
#import "Event.h"

@interface TicketDetailViewController : UITableViewController

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) Ticket *ticket;
@property(nonatomic,assign) BOOL iseditable;

@end
