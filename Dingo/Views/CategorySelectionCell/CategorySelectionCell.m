//
//  CategorySelectionViewCell.m
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "CategorySelectionCell.h"

#import "DataManager.h"
#import "CategoryCell.h"
#import "TwoModeButton.h"
#import "EventCategory.h"

@interface CategorySelectionCell () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray *allCategories;
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet TwoModeButton *multipleModeButton;



@end

@implementation CategorySelectionCell

#pragma mark - Initialization and Clean Up

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    self.multipleSelection = YES;
    self.selectedCategories = [NSMutableArray array];
//    [self.favoriteCategories addObjectsFromArray:@[@"Concerts", @"Comedy & Theatre"]];
//    self.favoriteCategory = [self.favoriteCategories firstObject];
    
    allCategories = [[DataManager shared] allCategories];
     
    return self;
}

- (void) refresh {
 
    allCategories = [[DataManager shared] allCategories];
    [self.collectionView reloadData];
    self.collectionView.userInteractionEnabled = !self.readOnly;
  
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    collectionView.allowsMultipleSelection = self.multipleSelection;
    
    CategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell"
                                                                   forIndexPath:indexPath];
    EventCategory *data;
    NSUInteger index = indexPath.row;
    
    
    data = allCategories[index];
    
//    if (self.multipleSelection) {
//        data = [manager allCategories][index];
//    } else {
//        NSString *catName = self.favoriteCategories[index];
//        data = [manager dataByCategoryName:catName];
//    }
    
    [cell buildWithData:data];
    
    if (self.multipleSelection) {
        cell.selected = [self.selectedCategories containsObject:data.category_id];
    } else {
        cell.selected = [self.selectedCategory isEqualToString:data.category_id];
    }
    
    if (cell.selected) {
        [collectionView selectItemAtIndexPath:indexPath
                                     animated:YES
                               scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
//    return self.multipleSelection ? [[DataManager shared] allCategories].count : self.favoriteCategories.count;
    return allCategories.count;
}

#pragma mark - UICollectionViewDelegate

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return self.favoriteCategories.count > 1;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.readOnly) {
        return;
    }
    
    EventCategory *data = allCategories[indexPath.row];
    
    self.selectedCategory = data.category_id;
    
    if (self.multipleSelection) {
        [self addCategoryToSelected:data.category_id];
    } else {
        if ([self.delegate respondsToSelector:@selector(didSelectedCategories:)]) {
            [self.delegate didSelectedCategories:@[self.selectedCategory]];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    EventCategory *data = allCategories[indexPath.row];
    
    if ([self.selectedCategory isEqualToString:data.category_id]) {
        self.selectedCategory = [self.selectedCategories firstObject];
        if ([self.delegate respondsToSelector:@selector(didSelectedCategories:)]) {
            [self.delegate didSelectedCategories:@[self.selectedCategory]];
        }
    }
    
    if (self.multipleSelection) {
        [self removeFavoriteCategory:data.category_id];
    }
}

#pragma mark - Setters

- (void)setMultipleSelection:(BOOL)multipleSelection {
    _multipleSelection = multipleSelection;
    self.collectionView.allowsMultipleSelection = self.multipleSelection;
    [self.collectionView reloadData];
}

- (void)addFavoriteCategory:(NSString *)category {
    if ([self.selectedCategories containsObject:category]) {
        return;
    }
    
    [self.selectedCategories addObject:category];
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedCategories:)]) {
        [self.delegate didSelectedCategories:self.selectedCategories];
    }

}

- (void)removeFavoriteCategory:(NSString *)category {
    [self.selectedCategories removeObject:category];
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedCategories:)]) {
        [self.delegate didSelectedCategories:self.selectedCategories];
    }

}

- (void)useAllCategories {
   
    NSArray *cats = [[DataManager shared] allCategories];
    for (EventCategory *category in cats) {
        NSString *name = category.category_id;
        if ([self.selectedCategories containsObject:name]) {
            continue;
        }
        
        [self.selectedCategories addObject:name];
    }

}

#pragma mark - UIActions

- (IBAction)changeMode {
    self.multipleSelection = !self.multipleSelection;
    self.multipleModeButton.selected = self.multipleSelection;
}

#pragma mark - Custom

- (void)buildByUserPreferences {
    BOOL multipleSelectionExpected = YES;
    self.multipleSelection = !multipleSelectionExpected;
    [self changeMode];
}

#pragma mark - Private

- (void)addCategoryToSelected:(NSString *)cat_id {
    [self.selectedCategories addObject:cat_id];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedCategories:)]) {
        [self.delegate didSelectedCategories:self.selectedCategories];
    }

}

@end
