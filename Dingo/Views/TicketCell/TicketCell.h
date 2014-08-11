//
//  EventView.h
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "EventCell.h"
#import "Ticket.h"

extern const CGFloat featureCellHeight;

@interface TicketCell : EventCell

+ (id)buildWithData:(Event *)data;
- (void)buildWithTicketData:(Ticket *)data;
- (void)loadUIFromXib;

@end
