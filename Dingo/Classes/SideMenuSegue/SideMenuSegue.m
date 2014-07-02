//
//  SideMenuSegue.m
//  Dingo
//
//  Created by logan on 6/12/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SideMenuSegue.h"

#import "ECSlidingViewController.h"

@implementation SideMenuSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    ECSlidingViewController *slidingVC = sourceViewController.slidingViewController;
    [slidingVC
     anchorTopViewOffScreenTo:ECRight
     animations:nil
     onComplete:^{
         UINavigationController *navVC = (UINavigationController *)slidingVC.topViewController;
         [navVC pushViewController:destinationViewController animated:NO];
         [slidingVC resetTopViewWithAnimations:nil
                                    onComplete:^{
                                        slidingVC.underLeftViewController = nil;
                                    }];
     }];
}

@end
