//
//  ManageListsCell.m
//  Dingo
//
//  Created by logan on 6/13/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "ManageListsCell.h"
#import "Ticket.h"
#import "DingoUISettings.h"
#import "DataManager.h"

@interface ManageListsCell ()

@end

@implementation ManageListsCell

#pragma mark - Setters


#pragma mark - Custom

- (void)buildWithTicketData:(Ticket *)data {
    [super buildWithTicketData:data];
    
    Event *event = [[DataManager shared] eventByID:data.event_id];
    
    [self buildWithData:event];
    
//    self.offers = [data[@"offers"] floatValue];
}

@end