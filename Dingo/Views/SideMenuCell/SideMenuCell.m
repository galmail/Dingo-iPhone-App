//
//  SideMenuCell.m
//  Dingo
//
//  Created by logan on 6/11/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SideMenuCell.h"

#import "DingoUISettings.h"

@implementation SideMenuCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    UIColor *newColor = [DingoUISettings makeHighLightedColorByColor:self.backgroundColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = newColor;
    self.selectedBackgroundView = bgColorView;
    
    return self;
}

@end
