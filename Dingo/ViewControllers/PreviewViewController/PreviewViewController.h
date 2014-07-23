//
//  PreviewViewController.h
//  Dingo
//
//  Created by logan on 6/20/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DataManager.h"

@interface PreviewViewController : UITableViewController

@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) Ticket *ticket;

@end
