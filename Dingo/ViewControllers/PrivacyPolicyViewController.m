//
//  PrivacyPolicyViewController.m
//  Dingo
//
//  Created by Tigran Aslanyan on 02.09.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "PrivacyPolicyViewController.h"

@interface PrivacyPolicyViewController (){
    
    IBOutlet UIWebView *webView;
}


@end

@implementation PrivacyPolicyViewController

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
    NSString* filePath =   [[NSBundle mainBundle] pathForResource:@"PrivacyPolicy.docx" ofType:nil];
    NSURLRequest * urlReq = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
    
    [webView loadRequest:urlReq];
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
