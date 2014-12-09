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

- (void)awakeFromNib {
    
    self.dateLabel.layer.cornerRadius = self.dateLabel.frame.size.height/2;
}

- (void)buildWithData:(Message *)data {

    NSString *userID = [[AppManager sharedManager].userInfo[@"id"] stringValue];
    
    Ticket *ticket =[[DataManager shared] ticketByID:data.ticket_id];
    
    if ([[ticket.user_id stringValue] isEqualToString:userID]) {
        self.icon = nil;
        if ([data.receiver_id isEqualToString:[ticket.user_id stringValue]]) {
            if (data.sender_avatar) {
                self.icon = [UIImage imageWithData:data.sender_avatar];
            } else {
                [WebServiceManager imageFromUrl:data.sender_avatar_url completion:^(id response, NSError *error) {
                    self.icon = [UIImage imageWithData:response];
                    data.sender_avatar = response;
                }];
            }
            if ([data.from_dingo boolValue]) {
                self.name = @"Dingo";
            } else {
                self.name = data.sender_name;
            }
        } else {
            if ([data.from_dingo boolValue]) {
                if (data.sender_avatar) {
                    self.icon = [UIImage imageWithData:data.sender_avatar];
                } else {
                    [WebServiceManager imageFromUrl:data.sender_avatar_url completion:^(id response, NSError *error) {
                        self.icon = [UIImage imageWithData:response];
                        data.sender_avatar = response;
                    }];
                }
                self.name = @"Dingo";
            } else {
                if (data.receiver_avatar) {
                    self.icon = [UIImage imageWithData:data.receiver_avatar];
                } else {
                    [WebServiceManager imageFromUrl:data.receiver_avatar_url completion:^(id response, NSError *error) {
                        self.icon = [UIImage imageWithData:response];
                        data.receiver_avatar = response;
                    }];
                }
                self.name = data.receiver_name;
            }
        }
        [[AppManager sharedManager] saveContext];
        
    } else {
        if ([data.from_dingo boolValue]) {
            if (data.sender_avatar) {
                self.icon = [UIImage imageWithData:data.sender_avatar];
            } else {
                [WebServiceManager imageFromUrl:data.sender_avatar_url completion:^(id response, NSError *error) {
                    self.icon = [UIImage imageWithData:response];
                    data.sender_avatar = response;
                }];
            }
            self.name = @"Dingo";
        } else {
        
            self.icon = nil;
            if (ticket.user_photo) {
                self.icon = [UIImage imageWithData:ticket.user_photo];
            }
            self.name = ticket.user_name;
        }

    }
    
    self.lastMessage = data.content;
    
    NSInteger unreadMessageCount = [[DataManager shared] unreadMessagesCountForTicket:ticket.ticket_id];
    if (unreadMessageCount) {
        
        NSString *unreadMessages = [NSString stringWithFormat:@"%ld", (long)unreadMessageCount];
        CGPoint center = self.dateLabel.center;
        
        CGRect boundingRect = [unreadMessages boundingRectWithSize:CGSizeMake(self.dateLabel.frame.size.width, 9999)
                                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                      attributes:@{NSFontAttributeName:self.dateLabel.font}
                                                         context:nil];

        CGRect frame = self.dateLabel.frame;
        frame.size.width = boundingRect.size.width > frame.size.height ?  boundingRect.size.width : frame.size.height ;
        self.dateLabel.frame = frame;
        self.dateLabel.center = center;
        self.dateLabel.text= unreadMessages;
    } else {
        self.dateLabel.hidden = YES;
    }
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
