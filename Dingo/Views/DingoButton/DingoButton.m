//
//  LoginButton.m
//  Dingo
//
//  Created by logan on 5/30/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DingoButton.h"

#import "DingoUISettings.h"

@implementation DingoButton

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [DingoUISettings makeHighLightedColorByColor:[DingoUISettings titleBackgroundColor]];
    } else {
        self.backgroundColor = [DingoUISettings titleBackgroundColor];
    }
    
}

@end
