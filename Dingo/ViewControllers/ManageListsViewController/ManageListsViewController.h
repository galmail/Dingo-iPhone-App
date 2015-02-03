//
//  ManageListsViewController.h
//  Dingo
//
//  Created by logan on 6/12/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@protocol ManageListsViewControllerDelegate <NSObject>

- (void)updateMyTicketsViewControllerButtons;

@end

@interface ManageListsViewController : UITableViewController

@property (nonatomic, assign) id<ManageListsViewControllerDelegate> delegate;
- (void)setTickets:(NSArray*)tickets;

@end
