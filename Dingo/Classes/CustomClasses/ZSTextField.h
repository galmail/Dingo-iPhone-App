//
//  ZSTextField.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/22/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZSTextFieldDelegate;

@interface ZSTextField : UITextField <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <ZSTextFieldDelegate, UITextFieldDelegate> delegate;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) CGRect popoverSize;
@property (nonatomic) UIColor *seperatorColor;
@property (nonatomic) BOOL applyFilter;

- (void) showToolbarWithDone;
- (void) setAutocompleteData:(NSArray*)autoCompleteData;

@end


@protocol ZSTextFieldDelegate <NSObject>

@required

- (NSArray *)dataForPopoverInTextField:(ZSTextField *)textField;

@optional

- (void)textField:(ZSTextField *)textField didEndEditingWithSelection:(NSDictionary *)result;
- (BOOL)textFieldShouldSelect:(ZSTextField *)textField;

@end