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
    
    __weak IBOutlet UILabel *lblOffers;
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
    lblOffers.font = [DingoUISettings fontWithSize:18];
}

- (void)setOffers:(NSInteger)offers {
    
    lblOffers.text = [NSString stringWithFormat:@"Offers (%d)", offers];
    
}

- (IBAction)editListing:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editListing)]) {
        [self.delegate editListing];
    }
}

- (IBAction)viewOffers:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewOffers)]) {
        [self.delegate viewOffers];
    }
}

@end
