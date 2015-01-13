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
#import "UIImageView+AFNetworking.h"




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
            if ([data.from_dingo boolValue]) {
               
                 if ([[DataManager shared] willShowDingoAvatar:ticket.ticket_id]) {
                     if (data.sender_avatar) {
                         [self.iconImageView setImage:[UIImage imageWithData:data.sender_avatar]];
                         
                     } else {
                         [self.iconImageView setImageWithURL:[NSURL URLWithString:data.sender_avatar_url] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                     }
                     self.name = @"Dingo";
                 }else{

                     [self.iconImageView setImageWithURL:[NSURL URLWithString:[[DataManager shared] returnAvatarUrl:ticket.ticket_id :data.sender_id ]] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                     self.name = data.sender_name;
                 }
                
            }else{
            if (data.sender_avatar) {
              
                [self.iconImageView setImage:[UIImage imageWithData:data.sender_avatar]];
            } else {

                [self.iconImageView setImageWithURL:[NSURL URLWithString:data.sender_avatar_url] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                
            }
                self.name = data.sender_name;
            }
          
            
            
        } else {
            if ([data.from_dingo boolValue]) {
                if (data.sender_avatar) {
                    
                    if ([[DataManager shared] willShowDingoAvatar:ticket.ticket_id]) {
                        [self.iconImageView setImage:[UIImage imageWithData:data.sender_avatar]];
                    }else{
                        
                        [self.iconImageView setImage:[UIImage imageWithData:ticket.user_photo]];
                    }
                    
                } else {
                    if ([[DataManager shared] willShowDingoAvatar:ticket.ticket_id]){
                        [self.iconImageView setImageWithURL:[NSURL URLWithString:data.sender_avatar_url] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                    }else{

                        [self.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",ticket.facebook_id]] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                        
                    }
                }
                self.name = @"Dingo";
            } else {
                if (data.receiver_avatar) {
                    
                    [self.iconImageView setImage:[UIImage imageWithData:data.receiver_avatar]];
                } else {

                    
                 [self.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",data.receiver_avatar_url]] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                }
                self.name = data.receiver_name;
            }
        }
       
        
    } else {
        
        if ([data.from_dingo boolValue]) {
            if (data.sender_avatar) {
                if ([[DataManager shared] willShowDingoAvatar:ticket.ticket_id]) {
                        [self.iconImageView setImage:[UIImage imageWithData:data.sender_avatar]];
                    self.name = @"Dingo";
                }else{
                   
                    [self.iconImageView setImage:[UIImage imageWithData:(ticket.user_photo==nil?data.sender_avatar:ticket.user_photo)]];
                    self.name=([data.receiver_id isEqualToString:[[AppManager sharedManager].userInfo[@"id"] stringValue]]?data.sender_name:data.receiver_name);
                }
                
                
            } else {
                
                if ([[DataManager shared] willShowDingoAvatar:ticket.ticket_id]){

                    [self.iconImageView setImageWithURL:[NSURL URLWithString:data.sender_avatar_url] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                  self.name = @"Dingo";
                }else{

                    [self.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",ticket.facebook_id]] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                   self.name=([data.receiver_id isEqualToString:[[AppManager sharedManager].userInfo[@"id"] stringValue]]?data.sender_name:data.receiver_name);
                }
            }
            
        } else {
        
            self.icon = nil;
            if (ticket.user_photo) {
                
                [self.iconImageView setImage:[UIImage imageWithData:ticket.user_photo]];
                 self.name = ticket.user_name;
            }else{
               
                
                self.name= ([data.receiver_id isEqualToString:[[AppManager sharedManager].userInfo[@"id"] stringValue]]?data.sender_name:data.receiver_name);
                [self.iconImageView setImageWithURL:[NSURL URLWithString:([data.receiver_id isEqualToString:[[AppManager sharedManager].userInfo[@"id"] stringValue]]?data.sender_avatar_url:data.receiver_avatar_url)] placeholderImage:[UIImage imageNamed:@"placeholder_avatar.jpg"]];
                
                
            }
           
        }

    }
    
    self.lastMessage = data.content;
    
    
    NSInteger unreadMessageCount = [[DataManager shared] unreadMessagesCountForTicket:data.conversation_id];
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
        self.dateLabel.hidden = false;
    } else {
        
        self.dateLabel.hidden = YES;
    }
}

#pragma mark - Setters

- (void)setIcon:(UIImage *)icon {
//    self.iconImageView.image = icon;
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
