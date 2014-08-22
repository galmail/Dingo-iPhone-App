//
//  TicketAlertCell
//  Dingo
//
//  Created by Tigran Aslanyan on 21.08.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//


#import "Alert.h"

@interface TicketAlertCell : UITableViewCell

- (void)buildWithData:(Alert *)data;
- (void)loadUIFromXib;

@end
