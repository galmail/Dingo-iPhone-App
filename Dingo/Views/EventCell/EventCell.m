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

- (void)buildWithData:(NSDictionary *)data {
    
    return;
    
    NSDictionary *dict = [[DataManager shared] dataByCategoryName:data[@"category"]];
    self.backImageView.image = [[UIImage imageNamed:dict[@"back"]] blurredImageWithRadius:5
                                                                               iterations:1
                                                                                tintColor:[UIColor colorWithWhite:.2
                                                                                                            alpha:.3]];
    self.iconImageView.image = [UIImage imageNamed:data[@"icon"]];
    self.name = data[@"name"];
    self.location = data[@"location"];
    self.begin = data[@"begin"];
    self.blurView.blurRadius = 5;
    self.blurView.dynamic = NO;
    self.blurView.hidden = YES;
}

@end
