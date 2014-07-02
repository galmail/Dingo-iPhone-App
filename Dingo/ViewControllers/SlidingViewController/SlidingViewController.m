//
//  SlidingViewController.m
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SlidingViewController.h"

@interface SlidingViewController ()

@end

@implementation SlidingViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
	self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
    [self.view addGestureRecognizer:self.panGesture];
    self.anchorRightPeekAmount = 70;
    self.anchorLeftRevealAmount = 250;
    self.underLeftWidthLayout = ECVariableRevealWidth;

    self.view.layer.shadowOpacity = .75;
    self.view.layer.shadowRadius = 10;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

@end
