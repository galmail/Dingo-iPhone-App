//
//  AnswerViewController.m
//  Dingo
//
//  Created by logan on 6/13/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "AnswerViewController.h"
#import "DingoUISettings.h"

@interface AnswerViewController ()

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UITextView *answerTextView;

@end

@implementation AnswerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.questionLabel.font = [DingoUISettings boldFontWithSize:15];
    self.answerTextView.font = [DingoUISettings lightFontWithSize:14];
    
    self.questionLabel.text = self.question;
    self.answerTextView.text = self.answer;
}

#pragma mark - Navigation

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
