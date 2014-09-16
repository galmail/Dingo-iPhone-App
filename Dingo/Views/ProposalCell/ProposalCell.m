//
//  Proposal.m
//  Dingo
//
//  Created by logan on 6/12/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "ProposalCell.h"
#import "DingoUISettings.h"
#import "DataManager.h"

@interface ProposalCell ()

@property (nonatomic, weak) IBOutlet UILabel *startPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;

@end

@implementation ProposalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nameLabel.font = [DingoUISettings fontWithSize:20];
    self.startPriceLabel.font = [DingoUISettings fontWithSize:20];
}

- (void)buildWithTicketData:(Ticket*)data {

    Event *event = [[DataManager shared] eventByID:data.event_id];
    [super buildWithData:event];
    
    [super buildWithTicketData:data];

    self.name = data.user_name;
    self.location = data.ticket_desc;
    
    if (data.user_photo) {
        self.imgIcon.image = [UIImage imageWithData:data.user_photo];
    }
    
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
