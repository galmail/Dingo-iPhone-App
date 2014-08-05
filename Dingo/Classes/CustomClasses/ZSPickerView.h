//
//  ZSPickerView.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/30/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSPickerView;

@protocol ZSPickerDelegate <NSObject>

@optional
- (void)pickerViewDidPressDone:(ZSPickerView*)picker withInfo:(id)selectionInfo;
- (void)pickerViewDidPressCancel:(ZSPickerView*)picker;

@end

@interface ZSPickerView : UIView

- (id)initWithItems:(NSArray*)items;

@property (nonatomic, assign) id<ZSPickerDelegate> delegate;
@property (nonatomic, assign) BOOL allowMultiSelection;

@end
