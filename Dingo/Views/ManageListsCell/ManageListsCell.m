//
//  ManageListsCell.m
//  Dingo
//
//  Created by logan on 6/13/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "ManageListsCell.h"

#import "DingoUISettings.h"

@interface ManageListsCell ()

@property (weak, nonatomic) IBOutlet UILabel *offersLabel;
@property (nonatomic) NSUInteger offers;

@end

@implementation ManageListsCell

#pragma mark - Setters

- (void)setOffers:(NSUInteger)offers {
    self.offersLabel.text = [NSString stringWithFormat:@"Offers (%lu)", (unsigned long)offers];
    self.offersLabel.textColor = offers ? [DingoUISettings titleBackgroundColor] : [DingoUISettings unimportantItemColor];
}

#pragma mark - Custom

- (void)buildWithData:(NSDictionary *)data {
    [super buildWithData:data];
    self.offers = [data[@"offers"] floatValue];
}

@end