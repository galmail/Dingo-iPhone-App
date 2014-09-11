//
//  BottomEditBar.m
//  Dingo
//
//  Created by Asatur Galstyan on 8/30/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "BottomEditBar.h"
#import "DingoUISettings.h"

@interface BottomEditBar () {
    
}

@end

@implementation BottomEditBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
       UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                      owner:self
                                    options:nil] objectAtIndex:0];
        
        [self addSubview:view];
        
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (IBAction)editListing:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editListing)]) {
        [self.delegate editListing];
    }
}

@end
