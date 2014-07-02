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

- (void)buildWithData:(NSDictionary *)data {
    self.icon = [UIImage imageNamed:data[@"icon"]];
    self.name = data[@"name"];
    self.lastMessage = data[@"message"];
    self.date = data[@"date"];
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
