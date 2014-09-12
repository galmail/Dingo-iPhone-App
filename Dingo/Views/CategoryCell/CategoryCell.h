//
//  Category.h
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//


#import "EventCategory.h"

@interface CategoryCell : UICollectionViewCell

@property (nonatomic, weak) UIImage *back;
@property (nonatomic, weak) NSString *name;

- (void)buildWithData:(EventCategory *)data;


@end
