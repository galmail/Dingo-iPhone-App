//
//  SideMenuViewController.m
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SideMenuViewController.h"

#import <MessageUI/MessageUI.h>

#import "ECSlidingViewController.h"
#import "DingoUISettings.h"

static const CGFloat cellHeight = 58;
static const NSUInteger cellsCount = 6;

static const NSUInteger contactUsRowIndex = 6;

static NSString * const supportEmail = @"info@dingoapp.co.uk";

@interface SideMenuViewController () <UITableViewDelegate, MFMailComposeViewControllerDelegate>{
    
    IBOutlet UILabel *lblTitle1;
    IBOutlet UILabel *lblTitle2;
    IBOutlet UILabel *lblTitle3;
    IBOutlet UILabel *lblTitle4;
    IBOutlet UILabel *lblTitle5;
    IBOutlet UILabel *lblTitle6;
    IBOutlet UILabel *lblTitle7;
}

@end

@implementation SideMenuViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //font
    lblTitle1.font = [DingoUISettings fontWithSize:12];
    lblTitle2.font = [DingoUISettings fontWithSize:14];
    lblTitle3.font = [DingoUISettings fontWithSize:14];
    lblTitle4.font = [DingoUISettings fontWithSize:14];
    lblTitle5.font = [DingoUISettings fontWithSize:14];
    lblTitle6.font = [DingoUISettings fontWithSize:14];
    lblTitle7.font = [DingoUISettings fontWithSize:14];

    //
    
    [self layoutTableView];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == contactUsRowIndex) {
        [self showEmailComposer];
        [self.slidingViewController resetTopViewWithAnimations:nil onComplete:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)layoutTableView {
    CGRect tableRect = self.tableView.frame;
    tableRect.origin.y = floorf((tableRect.size.height - cellHeight * cellsCount) / 2) - cellHeight;
    self.tableView.frame = tableRect;
}

- (void)showEmailComposer {
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail sending not available");
        return;
    }
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:@[supportEmail]];
    [mailComposer setMessageBody:@""
                          isHTML:YES];
    mailComposer.mailComposeDelegate = self;
    [self presentViewController:mailComposer animated:YES completion:nil];
}

@end
