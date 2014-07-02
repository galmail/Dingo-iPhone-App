//
//  AnswerViewController.m
//  Dingo
//
//  Created by logan on 6/13/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "AnswerViewController.h"

@interface AnswerViewController ()

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UITextView *answerTextView;

@end

@implementation AnswerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.questionLabel.text = self.question;
    self.answerTextView.text = [NSString stringWithFormat:@"Answer for %@", self.question];
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
