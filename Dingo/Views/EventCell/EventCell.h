//
//  EventCell.h
//  Dingo
//
//  Created by logan on 6/12/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

extern const CGFloat eventCellHeight;

#import "Event.h"

@interface EventCell : UITableViewCell

@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSDate *begin;

- (void)buildWithData:(Event *)data;

@end
