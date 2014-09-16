//
//  DingoField.m
//  Dingo
//
//  Created by logan on 5/30/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DingoField.h"

static const float fieldBorderSpace = 10;

@implementation DingoField

#pragma mark - UITextField

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }

    if (![self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    
    UIColor *textFieldColor = [self textFieldColor];
//    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder
//                                                                 attributes:@{NSForegroundColorAttributeName:textFieldColor}];
    self.layer.borderColor = textFieldColor.CGColor;
    self.layer.borderWidth = 1;
    
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, fieldBorderSpace, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, fieldBorderSpace, 0);
}

#pragma mark - Private

- (UIColor *)textFieldColor {
    return [UIColor colorWithRed:219. / 255
                           green:1
                            blue:1
                           alpha:1];
}

@end
