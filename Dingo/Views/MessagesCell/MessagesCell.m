//
//  MessagesCell.m
//  Dingo
//
//  Created by logan on 6/3/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "MessagesCell.h"

#import "DingoUtilites.h"


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
    
    if (data.sender_avatar) {
        self.icon = [UIImage imageWithData:data.sender_avatar];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:data.sender_avatar_url]];
        data.sender_avatar = imageData;
        [data.managedObjectContext save:nil];
        self.icon = [UIImage imageWithData:data.sender_avatar];
    }
    self.name = data.sender_name;
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
