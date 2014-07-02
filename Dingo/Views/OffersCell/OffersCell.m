//
//  OffersCell.m
//  Dingo
//
//  Created by logan on 6/10/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "OffersCell.h"

#import "TwoModeButton.h"

const CGFloat offersCellHeight = 86;
NSString * const OfferCellDidChangeAcceptedStateNotification = @"accepted state changed";

@interface OffersCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet TwoModeButton *acceptButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation OffersCell

#pragma mark - Clear Up

#pragma mark - Setters

- (void)setOfferAccepted:(BOOL)offerAccepted {
    _offerAccepted = offerAccepted;
    self.acceptButton.selected = offerAccepted;
}

- (void)setIcon:(UIImage *)icon {
    self.iconImageView.image = icon;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

#pragma mark - UIActions

- (IBAction)accept {
    [[NSNotificationCenter defaultCenter] postNotificationName:OfferCellDidChangeAcceptedStateNotification
                                                        object:self];
}

- (IBAction)writeMessage {

}

@end
