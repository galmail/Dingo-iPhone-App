//
//  EventsViewController.h
//  Dingo
//
//  Created by logan on 6/5/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "Event.h"

@interface TicketsViewController : UITableViewController

@property (nonatomic, strong) Event *eventData;

@end

extern NSString *sendToWeb;
