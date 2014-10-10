//
//  MessagesCell.m
//  Dingo
//
//  Created by logan on 6/3/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "MessagesCell.h"

#import "DingoUtilites.h"
#import "DataManager.h"
#import "WebServiceManager.h"

const CGFloat messagesCellHeight = 82;

@interface MessagesCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@implementation MessagesCell

#pragma mark - Custom

- (void)buildWithData:(Message *)data {

    NSString *userID = [[AppManager sharedManager].userInfo[@"id"] stringValue];
    
    Ticket *ticket =[[DataManager shared] ticketByID:data.ticket_id];
    
    if ([[ticket.user_id stringValue] isEqualToString:userID]) {
        self.icon = nil;
        if ([data.receiver_id isEqualToString:[ticket.user_id stringValue]]) {
            [WebServiceManager imageFromUrl:data.sender_avatar_url completion:^(id response, NSError *error) {
                self.icon = [UIImage imageWithData:response];
            }];
            self.name = data.sender_name;
        } else {
            [WebServiceManager imageFromUrl:data.receiver_avatar_url completion:^(id response, NSError *error) {
                self.icon = [UIImage imageWithData:response];
            }];
            self.name = data.receiver_name;
        }
        
    } else {
        self.icon = nil;
        if (ticket.user_photo) {
            self.icon = [UIImage imageWithData:ticket.user_photo];
        }
        
        self.name = ticket.user_name;

    }
    
        self.lastMessage = data.content;
    self.date = nil;//data[@"date"];
}

#pragma mark - Setters

- (void)setIcon:(UIImage *)icon {
    self.iconImageView.image = icon;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setLastMessage:(NSString *)lastMessage {
    self.lastMessageLabel.text = lastMessage;
}

- (void)setDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [DingoUtilites dateFormatter];
    [dateFormatter setDateFormat:@"H:mm a"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
}


@end
