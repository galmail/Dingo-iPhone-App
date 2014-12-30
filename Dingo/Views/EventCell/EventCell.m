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
#import "DingoUISettings.h"
#import "UIImage+Overlay.h"
#import "WebServiceManager.h"

const CGFloat eventCellHeight = 78;

@interface EventCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backImageView;
@property (nonatomic, weak) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIButton *btnBell;

@end

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if ([NSStringFromClass([self class]) isEqual:@"EventCell"]) {
        self.nameLabel.font = [DingoUISettings boldFontWithSize:24];
        self.locationLabel.font = [DingoUISettings fontWithSize:14];
        self.timeLabel.font = [DingoUISettings fontWithSize:12];
    }
    
    if ([NSStringFromClass([self class]) isEqual:@"ManageListsCell"]) {
        self.nameLabel.font = [DingoUISettings fontWithSize:17];
        self.locationLabel.font = [DingoUISettings fontWithSize:13];
        self.timeLabel.font = [DingoUISettings fontWithSize:12];
    }
    
}

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
    if ([name isEqualToString:@"Event Pending Validation"]) {
        [self.nameLabel setTextColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0]];
        [self.nameLabel setNumberOfLines:2];
        
      
    }
}

- (void)setLocation:(NSString *)location {
    _location = location;
    self.locationLabel.text = location;
}

- (void)setOn:(BOOL)on {
    self.btnBell.selected = on;
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
        if (data.thumbUrl.length > 0) {
            if (data) {
            [WebServiceManager imageFromUrl:data.thumbUrl completion:^(id response, NSError *error) {
                
                data.thumb = response;
                self.iconImageView.image = [UIImage imageWithData:data.thumb];
                
                [[AppManager sharedManager] saveContext];
            }];
            }
            
        } else {
            if (category.thumb) {
                self.iconImageView.image = [UIImage imageWithData:category.thumb];
            } else {
                if (category) {
                    
                
                [WebServiceManager imageFromUrl:category.thumbUrl completion:^(id response, NSError *error) {
                    category.thumb = response;
                    self.iconImageView.image = [UIImage imageWithData:category.thumb];
                    
                    [[AppManager sharedManager] saveContext];
                }];
                }
            }
        }
        
    }
   
    self.name = data.name;
    if (!NSSTRING_HAS_DATA(data.name)) {
        self.name=@"Event Pending Validation";
        self.iconImageView.image=[UIImage imageNamed:@"PlaceHolderManageListing.jpg"];
    }
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
