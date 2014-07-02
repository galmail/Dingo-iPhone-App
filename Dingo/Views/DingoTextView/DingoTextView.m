//
//  DingoTextView.m
//  Dingo
//
//  Created by logan on 6/3/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DingoTextView.h"

static const uint lineCount = 2;
static NSString * const placeholderText = @"Description...";

@interface DingoTextView () <UITextViewDelegate>

@end

@implementation DingoTextView

#pragma mark - UITextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    self.delegate = self;
    self.text = placeholderText;
    
    return self;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.text isEqualToString:placeholderText]) {
        self.text = @"";
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([self.text isEqualToString:@""]) {
        self.text = placeholderText;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSString *newString = [self.text stringByReplacingCharactersInRange:range withString:text];
    return [self checkLinesCountWithNewString:newString];
}

#pragma mark - Private

- (BOOL)checkLinesCountWithNewString:(NSString *)newString {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{NSFontAttributeName: self.font,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    CGFloat contentHeight = [newString boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height * 2)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes
                                                    context:nil].size.height;
    
    uint lines = ceilf(contentHeight / self.font.lineHeight);
    NSLog(@"%d", lines);
    return lines <= lineCount;
}

@end
