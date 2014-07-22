//
//  Category.m
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "CategoryCell.h"


@interface CategoryCell ()

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UIImageView *backImageView;
@property (nonatomic, weak) IBOutlet UIView *foregroundView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *indicatorImageView;

@end

@implementation CategoryCell

#pragma mark - UICollectionViewCell

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.indicatorImageView.hidden = !selected;
    self.foregroundView.hidden = !selected;
}

#pragma mark - Custom

- (void)buildWithData:(EventCategory *)data {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    [self addSubview:self.view];
    
    if (data.thumb) {
        self.back = [UIImage imageWithData:data.thumb];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:data.thumbUrl]];
        data.thumb = imageData;
        [data.managedObjectContext save:nil];
        
        self.back = [UIImage imageWithData:data.thumb];
    }
    
    self.name = data.name;
}

#pragma mark - Setters

- (void)setBack:(UIImage *)back {
    self.backImageView.image = back;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (NSString *)name {
    return self.nameLabel.text;
}

- (UIImage *)back {
    return self.backImageView.image;
}

@end
