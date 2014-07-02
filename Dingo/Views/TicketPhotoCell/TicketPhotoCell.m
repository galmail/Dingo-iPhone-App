//
//  TicketPhotoCell.m
//  Dingo
//
//  Created by logan on 6/19/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "TicketPhotoCell.h"

@interface TicketPhotoCell ()

@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;

@end

@implementation TicketPhotoCell

#pragma mark - Setters

- (void)setTicketPhoto:(UIImage *)ticketPhoto {
    _ticketPhoto = ticketPhoto;
    self.photoImageView.image = ticketPhoto;
}

#pragma mark - UIActions

- (IBAction)removePhoto {
    if (!self.delegate) {
        return;
    }
    
    [self.delegate removePhotoCell:self];
}

@end
