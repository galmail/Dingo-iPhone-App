//
//  MutualFriendCell.m
//  Dingo
//
//  Created by Pierrot Léchot on 14/11/2014.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "MutualFriendCell.h"

@implementation MutualFriendCell

- (void)awakeFromNib{

    [_nameLabel setAdjustsFontSizeToFitWidth:YES];
    [[_profileImage layer] setMasksToBounds:YES];
    [[_profileImage layer] setCornerRadius:31];
}

@end
