//
//  CategoriesModeButton.m
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "TwoModeButton.h"

#import "DingoUISettings.h"

@implementation TwoModeButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }

    self.layer.borderColor = [DingoUISettings backgroundColor].CGColor;
    self.layer.borderWidth = 1;
    self.selected = NO;
    
    return self;
}

#pragma mark - Setters

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = selected ? [DingoUISettings backgroundColor] : [UIColor clearColor];
    [self setTitleColor:selected ? [DingoUISettings foregroundColor] : [DingoUISettings backgroundColor]
               forState:UIControlStateNormal];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.selected = highlighted;
}

@end
