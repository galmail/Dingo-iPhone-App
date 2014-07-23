//
//  EventCell.m
//  Dingo
//
//  Created by logan on 6/12/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "EventCell.h"

#import "FXBlurView.h"

#import "DataManager.h"
#import "DingoUtilites.h"
#import "UIImage+Overlay.h"

const CGFloat eventCellHeight = 78;

@interface EventCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backImageView;
@property (nonatomic, weak) IBOutlet FXBlurView *blurView;

@end

@implementation EventCell

#pragma mark - Setters

- (void)setBegin:(NSDate *)begin {
    _begin = begin;
    NSDateFormatter *dateFormatter = [DingoUtilites dateFormatter];
    [dateFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [dateFormatter stringFromDate:begin];
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;
}

- (void)setLocation:(NSString *)location {
    _location = location;
    self.locationLabel.text = location;
}

#pragma mark - Custom

- (void)buildWithData:(Event *)data {
    
    EventCategory *category = [[DataManager shared] dataByCategoryID:data.category_id];
    
    if (category.thumb) {
        self.backImageView.image = [[UIImage imageWithData:category.thumb] blurredImageWithRadius:5
                                                                                       iterations:1
                                                                                        tintColor:[UIColor colorWithWhite:0.2 alpha:0.3]];
    }
    
    if (data.thumb) {
         self.iconImageView.image = [UIImage imageWithData:data.thumb];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:data.thumbUrl]];
        data.thumb = imageData;
        [data.managedObjectContext save:nil];
        self.iconImageView.image = [UIImage imageWithData:data.thumb];
    }
   
    self.name = data.name;
    self.location = [self eventLocation:data];
    self.begin = data.date;
    self.blurView.blurRadius = 5;
    self.blurView.dynamic = NO;
    self.blurView.hidden = YES;
}

- (NSString *)eventLocation:(Event *)data {
    
    NSString *location = @"";
    if (data.address.length > 0) {
        location = data.address;
    }
    
    if (data.city.length > 0) {
        
        if (location.length > 0) {
            location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", data.city]];
        } else {
            location = data.city;
        }
    }
    
    if (data.postalCode.length > 0) {
        if (location.length > 0) {
            location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", data.postalCode]];
        } else {
            location = data.postalCode;
        }
    }
    
    return location;
}

@end
