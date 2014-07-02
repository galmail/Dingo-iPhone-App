//
//  DingoNavigationControllerViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DingoNavigationController.h"

#import "DingoUISettings.h"

@implementation DingoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [DingoUISettings titleBackgroundColor];
    self.toolbar.backgroundColor = [DingoUISettings titleBackgroundColor];
}

@end
