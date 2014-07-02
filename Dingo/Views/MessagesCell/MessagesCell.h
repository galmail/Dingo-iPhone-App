//
//  MessagesCell.h
//  Dingo
//
//  Created by logan on 6/3/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

extern const CGFloat messagesCellHeight;

@interface MessagesCell : UITableViewCell

@property (nonatomic, weak) UIImage *icon;
@property (nonatomic, weak) NSString *name;
@property (nonatomic, weak) NSString *lastMessage;
@property (nonatomic, weak) NSDate *date;

- (void)buildWithData:(NSDictionary *)data;

@end
