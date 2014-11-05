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
#import "MessagesViewController.h"
#import "ChatViewController.h"
#import "AppManager.h"
#import "DataManager.h"

static const NSUInteger listTicketsVCIndex = 2;

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

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadMessages];
    if (unreadMessages) {
        [self messagesTabBarItem].badgeValue = [NSString stringWithFormat:@"%ld",(long)unreadMessages];
        
        UIViewController *messagesVC = self.viewControllers[3];
        NSLog(@"messagesVC %@", messagesVC);
        if ([messagesVC isKindOfClass:[MessagesViewController class]]) {
            [(MessagesViewController*)messagesVC groupMessagesByUser];
        }
        if ([messagesVC isKindOfClass:[ChatViewController class]]) {
            [(ChatViewController*)messagesVC reloadMessages];
        }
    } else {
        [self messagesTabBarItem].badgeValue = nil;
    }
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
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
    NSArray *items = self.tabBar.items;
    
    for (UITabBarItem *item in items) {
        UIImage *image = item.image;
        item.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image = [image imageWithColor:[DingoUISettings backgroundColor]];
        item.selectedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.titlePositionAdjustment = UIOffsetMake(0, -3);
    }
}

- (UITabBarItem *)messagesTabBarItem {
    return [self.viewControllers[3] tabBarItem];
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
