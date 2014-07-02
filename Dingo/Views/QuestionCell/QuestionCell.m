//
//  QuestionCell.m
//  Dingo
//
//  Created by logan on 6/13/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "QuestionCell.h"

@interface QuestionCell ()

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;

@end

@implementation QuestionCell

- (void)setQuestion:(NSString *)question {
    _question = question;
    self.questionLabel.text = question;
}

@end
