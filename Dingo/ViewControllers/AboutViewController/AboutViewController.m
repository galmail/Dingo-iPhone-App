//
//  AboutViewController.m
//  Dingo
//
//  Created by Tigran Aslanyan on 20.08.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
