//
//  ZSDatePicker.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/29/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ZSDatePicker.h"

@interface ZSDatePicker() {
    UIDatePicker *datePicker;
}

@end

@implementation ZSDatePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDate:(NSDate*)date {
    
    self = [super init];
    if (self) {

        if (!date) {
            date = [NSDate date];
        }
        
		CGRect datePickerFrame;
        
        self.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 260.0);
        datePickerFrame = CGRectMake(0.0, 44.5, self.frame.size.width, 216.0);
        
        UIToolbar *toolbar = [[UIToolbar alloc]
                              initWithFrame: CGRectMake(0.0, 0.0, self.frame.size.width, datePickerFrame.origin.y - 0.5)];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                         target: self
                                         action: @selector(cancel)];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                      target: self
                                      action: nil];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                    target: self
                                    action: @selector(done)];
        
        [toolbar setItems: @[cancelButton, flexSpace, doneBtn]
                 animated: YES];
        [self addSubview: toolbar];
        
        
        datePicker = [[UIDatePicker alloc] initWithFrame:datePickerFrame];
        datePicker.date = date;
        [self addSubview: datePicker];
    }
    
    return self;
}

- (void)setDate:(NSDate*)date {
    datePicker.date = date;    
}

- (void)setPickerMode:(UIDatePickerMode)mode {
    datePicker.datePickerMode = mode;
}

- (void)done {
    
    if ([self.delegate respondsToSelector: @selector(pickerDidPressDone:withDate:)]) {
        [self.delegate pickerDidPressDone:self withDate:datePicker.date];
    }
}


- (void)cancel {
    
    if ([self.delegate respondsToSelector: @selector(pickerDidPressCancel:)]) {
        [self.delegate pickerDidPressCancel:self];
    }

}

@end
