//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "HomeTabBarController.h"

#import "ECSlidingViewController.h"
#import "UIImage+Overlay.h"

#import "DingoUISettings.h"
#import "DingoUtilites.h"
#import "ListTicketsViewController.h"
#import "AppManager.h"
#import "DataManager.h"

static const NSUInteger listTicketsVCIndex = 1;

@interface HomeTabBarController () <UIActionSheetDelegate, UITabBarControllerDelegate>

@property (nonatomic) NSInteger nextTabBarIndex;
@property (nonatomic) BOOL menuTapped;

@end

@implementation HomeTabBarController

#pragma mark - UITabBarController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuController"];
    [self adjustTabBar];
    self.navigationItem.hidesBackButton = YES;
    self.nextTabBarIndex = -1;
    self.delegate = self;
}

- (void)updateMessageCount {
    NSInteger unreadMessages = [[DataManager shared] unreadMessagesCount];
    
    if (unreadMessages) {
        [self messagesTabBarItem].badgeValue = [NSString stringWithFormat:@"%ld",(long)unreadMessages];
    } else {
        [self messagesTabBarItem].badgeValue = nil;
    }
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    self.menuTapped=NO;
    if (self.selectedViewController != [self listTicketsVC]) {
        return YES;
    }
    
    NSUInteger nextVCIndex = [self.viewControllers indexOfObject:viewController];
    if (nextVCIndex == listTicketsVCIndex) {
        return YES;
    }
    
    if (![self listTicketsVC].changed) {
        return YES;
    }
    
    self.nextTabBarIndex = nextVCIndex;
    [self showActionSheet];
    
    return NO;
}

#pragma mark - UIActions

- (IBAction)menuTapped:(id)sender {
    
    self.menuTapped = YES;
    
    if (self.selectedViewController != [self listTicketsVC]) {
        [self.slidingViewController anchorTopViewTo:ECRight];
        return;
    }
    
    if (![self listTicketsVC].changed) {
        [self.slidingViewController anchorTopViewTo:ECRight];
        return;
    }
    
    [self showActionSheet];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            NSLog(@"Save");
            [[self listTicketsVC] saveDraft];
            break;
            
        case 1:
            NSLog(@"Don't Save");
            [AppManager sharedManager].draftTicket = nil;
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_event_paymentOptions"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_event_deliveryOptions"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"kDingo_ticket_ticket_id"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDingo_ticket_editTicket"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            break;
    }
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (self.menuTapped) {
        self.menuTapped = NO;
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
    
    if (self.nextTabBarIndex >= 0) {
        self.selectedIndex = self.nextTabBarIndex;
        self.nextTabBarIndex = -1;
    }
}



#pragma mark - Private

- (void)adjustTabBar {
	//[[UITabBar appearance] setTintColor:[UIColor whiteColor]];
	
	UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:0];
	UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:1];
	UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:2];
	UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:3];
	
	(void)[tabBarItem1 initWithTitle:@"Home"
							   image:[[UIImage imageNamed:@"home_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
					   selectedImage:[[UIImage imageNamed:@"Home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	
	(void)[tabBarItem2 initWithTitle:@"Sell Tickets"
							   image:[[UIImage imageNamed:@"list_tickets_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
					   selectedImage:[[UIImage imageNamed:@"Sell"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

	(void)[tabBarItem3 initWithTitle:@"Messages"
							   image:[[UIImage imageNamed:@"messages_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
					   selectedImage:[[UIImage imageNamed:@"Messages"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

	(void)[tabBarItem4 initWithTitle:@"Search"
							   image:[[UIImage imageNamed:@"search_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
					   selectedImage:[[UIImage imageNamed:@"Search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	
	[[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:0.0f],
														NSForegroundColorAttributeName : [UIColor whiteColor]}
											 forState:UIControlStateNormal];
	[[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:0.0f],
														NSForegroundColorAttributeName : [UIColor whiteColor]}
											 forState:UIControlStateSelected];
	[[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
}

- (UITabBarItem *)messagesTabBarItem {
    return [self.viewControllers[2] tabBarItem];
}

- (ListTicketsViewController *)listTicketsVC {
    return self.viewControllers[listTicketsVCIndex];
}

- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save", @"Don't Save", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

@end
