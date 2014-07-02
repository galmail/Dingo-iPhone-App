//
//  RoundedImageView.m
//  Dingo
//
//  Created by logan on 6/10/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "RoundedImageView.h"

@implementation RoundedImageView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    
    CGSize sz = self.bounds.size;
    self.layer.cornerRadius = fminf(sz.width / 2, sz.height / 2);
    self.clipsToBounds = YES;
    
    return self;
}

@end
