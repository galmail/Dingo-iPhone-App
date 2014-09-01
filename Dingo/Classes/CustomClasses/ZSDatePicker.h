//
//  ZSDatePicker.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/29/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSDatePicker;

@protocol ZSDatePickerDelegate <NSObject>

@optional

- (void)pickerDidPressDone:(ZSDatePicker*)picker withDate:(NSDate *)date;
- (void)pickerDidPressCancel:(ZSDatePicker*)picker;

@end

@interface ZSDatePicker : UIView

@property (nonatomic, assign) id<ZSDatePickerDelegate> delegate;

- (id)initWithDate:(NSDate*)date;
- (void)setDate:(NSDate*)date;

@end
