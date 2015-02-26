//
//  ZSTextView.m
//  Dingo
//
//  Created by Asatur Galstyan on 8/5/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ZSTextView.h"

@implementation ZSTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor colorWithRed:(200.0/255.0) green:(200.0/255.0) blue:(200.0/255.0) alpha:1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor colorWithRed:(200.0/255.0) green:(200.0/255.0) blue:(200.0/255.0) alpha:1]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( self.placeHolderLabel == nil )
        {
            self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,8,self.bounds.size.width - 16,0)];
            self.placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.placeHolderLabel.numberOfLines = 0;
            self.placeHolderLabel.font = self.font;
            self.placeHolderLabel.backgroundColor = [UIColor clearColor];
            self.placeHolderLabel.textColor = self.placeholderColor;
            self.placeHolderLabel.alpha = 0;
            self.placeHolderLabel.tag = 999;
            [self addSubview:self.placeHolderLabel];
        }
        
        self.placeHolderLabel.text = self.placeholder;
        [self.placeHolderLabel sizeToFit];
        [self sendSubviewToBack:self.placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

- (void) showToolbarWithDone {
    
    UIView * keyboardHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    keyboardHeader.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
    keyboardHeader.layer.borderColor = [UIColor colorWithRed:173/255.0f green:179/255.0f blue:189/255.0f alpha:1.0f].CGColor;
    keyboardHeader.layer.borderWidth = 1.0f;
    
    
    UIImage *image = [UIImage imageNamed:@"barButton"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 12, 0.0, 12)];
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(240, 6, 70, 33)];
    
    [btnDone setBackgroundImage:image forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    [btnDone setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyboardHeader addSubview:btnDone];
    self.inputAccessoryView = keyboardHeader;
    
}

- (void)closeKeyboard:(id)sender {
    
    [self resignFirstResponder];
    
}

@end