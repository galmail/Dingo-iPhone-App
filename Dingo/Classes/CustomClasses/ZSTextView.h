//
//  ZSTextView.h
//  Dingo
//
//  Created by Asatur Galstyan on 8/5/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSTextView : UITextView

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;
- (void)showToolbarWithDone;

@end