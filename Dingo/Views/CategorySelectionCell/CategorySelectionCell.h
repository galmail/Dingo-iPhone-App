//
//  CategorySelectionViewCell.h
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@interface CategorySelectionCell : UITableViewCell

@property (nonatomic) BOOL multipleSelection;

- (void)addFavoriteCategory:(NSString *)category;
- (void)removeFavoriteCategory:(NSString *)category;
- (void)useAllCategories;

- (void)buildByUserPreferences;

@end
