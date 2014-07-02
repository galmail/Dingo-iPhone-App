//
//  OffersCell.h
//  Dingo
//
//  Created by logan on 6/10/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

extern const CGFloat offersCellHeight;
extern NSString * const OfferCellDidChangeAcceptedStateNotification;

@interface OffersCell : UITableViewCell

@property (nonatomic, weak) UIImage *icon;
@property (nonatomic, weak) NSString *name;
@property (nonatomic) BOOL offerAccepted;

@end
