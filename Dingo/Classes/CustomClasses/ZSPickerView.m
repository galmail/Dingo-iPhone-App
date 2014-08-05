//
//  ZSPickerView.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/30/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ZSPickerView.h"

@interface ZSPickerView() <UIPickerViewDataSource, UIPickerViewDelegate> {
 
    NSArray *items;
    UIPickerView *picker;
    
    NSDictionary *selectedValue;
}

@end

@implementation ZSPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithItems:(NSArray*)pickerItems {

    self = [super init];
    if (self) {
        
        items = pickerItems;
        
        CGRect pickerFrame;
        
        self.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 260.0);
        pickerFrame = CGRectMake(0.0, 44.5, self.frame.size.width, 216.0);
        
        UIToolbar *toolbar = [[UIToolbar alloc]
                              initWithFrame: CGRectMake(0.0, 0.0, self.frame.size.width, pickerFrame.origin.y - 0.5)];
        
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
        
        
        picker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        picker.dataSource = self;
        picker.delegate = self;
        [self addSubview: picker];
    }
    return self;
}

- (void)done {
    
    if ([self.delegate respondsToSelector: @selector(pickerViewDidPressDone:withInfo:)]) {
        [self.delegate pickerViewDidPressDone:self withInfo:selectedValue];
    }
}


- (void)cancel {
    
    if ([self.delegate respondsToSelector: @selector(pickerViewDidPressCancel:)]) {
        [self.delegate pickerViewDidPressCancel:self];
    }
    
}

#pragma mark UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [items count];
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [items[component] count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return items[component][row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedValue = items[component][row];
}

@end
