//
//  ZSPickerView.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/30/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ZSPickerView.h"

@interface ZSPickerView() <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {
 
    NSArray *items;
    UIPickerView *picker;
    UITableView *tblPicker;
    
    NSDictionary *selectedValue;
    NSMutableArray *selectedItems;
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

- (id)initWithItems:(NSArray*)pickerItems allowMultiSelection:(BOOL)allow {

    self = [super init];
    if (self) {
        
        items = pickerItems;
        
        self.allowMultiSelection = allow;
        
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
        
        
        if (allow) {
            
            selectedItems = [[NSMutableArray alloc] init];
            
            tblPicker = [[UITableView alloc] initWithFrame:pickerFrame];
            tblPicker.separatorStyle = UITableViewCellSeparatorStyleNone;
            tblPicker.dataSource = self;
            tblPicker.delegate = self;
            
            [self addSubview: tblPicker];
            
        } else {
        
            picker = [[UIPickerView alloc] initWithFrame:pickerFrame];
            picker.dataSource = self;
            picker.delegate = self;
            
            [self addSubview: picker];
            
        }
    }
    return self;
}

- (void)done {
    
    if ([self.delegate respondsToSelector: @selector(pickerViewDidPressDone:withInfo:)]) {
        
        if (self.allowMultiSelection) {
            
            if  (selectedItems.count == 0) {
                [selectedItems addObject:items[0]];
            }
            
            [self.delegate pickerViewDidPressDone:self withInfo:selectedItems];
        } else {
            if  (!selectedValue) {
                selectedValue = items[0];
            }
            
            [self.delegate pickerViewDidPressDone:self withInfo:selectedValue];
        }
    }
}


- (void)cancel {
    
    if ([self.delegate respondsToSelector: @selector(pickerViewDidPressCancel:)]) {
        [self.delegate pickerViewDidPressCancel:self];
    }
    
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    NSString *value = items[indexPath.row];
    if ([selectedItems indexOfObject:value]!= NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *value = items[indexPath.row];
    if ([selectedItems indexOfObject:value] == NSNotFound) {
        [selectedItems addObject:value];
    } else {
        [selectedItems removeObject:value];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark UIPickerView methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [items count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return items[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedValue = items[row];
}

@end
