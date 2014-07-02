//
//  RoundedButton.m
//  Dingo
//
//  Created by logan on 5/30/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    self.layer.cornerRadius = self.frame.size.height / 2;
    
    return self;
}

@end
