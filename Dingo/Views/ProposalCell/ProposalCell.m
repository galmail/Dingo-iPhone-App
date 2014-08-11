//
//  Proposal.m
//  Dingo
//
//  Created by logan on 6/12/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "ProposalCell.h"
#import "DingoUISettings.h"

@interface ProposalCell ()

@property (nonatomic, weak) IBOutlet UILabel *startPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation ProposalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nameLabel.font = [DingoUISettings fontWithSize:20];
    self.startPriceLabel.font = [DingoUISettings fontWithSize:20];
}

- (void)buildWithTicketData:(Ticket*)data {
    [super buildWithTicketData:data];
}

- (void)buildWithData:(Event *)data {
    [super buildWithData:data];
}

- (void)setBegin:(NSDate *)begin {
    // don't remove, because proposal cell didn't have time label
}

- (void)setName:(NSString *)name {
    [super setName:name];
}

- (void)setLocation:(NSString *)location {
    [super setLocation:location];
}



@end
