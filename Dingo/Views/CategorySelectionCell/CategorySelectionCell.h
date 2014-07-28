//
//  CategorySelectionViewCell.h
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@protocol CategorySelectionDelegate <NSObject>

@optional
- (void)didSelectedCategories:(NSArray*)selectionArray;

@end

@interface CategorySelectionCell : UITableViewCell

@property (nonatomic) BOOL multipleSelection;
@property (nonatomic, strong) NSString *selectedCategory;
@property (nonatomic, strong) NSMutableArray *selectedCategories;
@property (nonatomic, assign) id<CategorySelectionDelegate> delegate;

- (void)addFavoriteCategory:(NSString *)category;
- (void)removeFavoriteCategory:(NSString *)category;
- (void)useAllCategories;
- (void)refresh;
- (void)buildByUserPreferences;

@end
