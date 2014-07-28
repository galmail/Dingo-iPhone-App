//
//  ZSLoadingView.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/28/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DingoUISettings.h"

@interface ZSLoadingView : UIView

- (id)initWithLabel:(NSString*)label;

- (void)show;
- (void)hide;

@end
