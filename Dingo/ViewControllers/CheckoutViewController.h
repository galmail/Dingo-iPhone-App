//
//  CheckoutViewController.h
//  Dingo
//
//  Created by Asatur Galstyan on 9/22/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Ticket.h"

@interface CheckoutViewController : UITableViewController

@property (nonatomic) Ticket *ticket;
@property (nonatomic) Event *event;

@end
