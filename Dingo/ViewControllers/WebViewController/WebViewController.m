//
//  WebViewController.m
//  Dingo
//
//  Created by Nonnus on 29/01/15.
//  Copyright (c) 2015 Dingo. All rights reserved.
//

#import "WebViewController.h"
#import "Event.h"

@interface WebViewController () {
	__weak IBOutlet UIWebView *webView;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	NSString *url = self.event.primary_ticket_seller_url;
	if (![url hasPrefix:@"http://"]) url = [@"http://" stringByAppendingString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	[webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)back:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
