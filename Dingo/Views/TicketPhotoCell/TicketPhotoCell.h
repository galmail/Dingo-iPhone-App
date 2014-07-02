//
//  TicketPhotoCell.h
//  Dingo
//
//  Created by logan on 6/19/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@protocol TicketsPhotoCellDelegate

- (void)removePhotoCell:(id)photoCell;

@end

@interface TicketPhotoCell : UICollectionViewCell

@property (nonatomic, weak) UIImage *ticketPhoto;
@property (nonatomic, weak) id <TicketsPhotoCellDelegate> delegate;

@end
