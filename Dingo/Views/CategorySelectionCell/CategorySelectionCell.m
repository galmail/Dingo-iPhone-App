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

@interface CategorySelectionCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet TwoModeButton *multipleModeButton;
@property (nonatomic, strong) NSMutableArray *favoriteCategories;
@property (nonatomic, strong) NSString *favoriteCategory;

@end

@implementation CategorySelectionCell

#pragma mark - Initialization and Clean Up

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    self.multipleSelection = YES;
    self.favoriteCategories = [NSMutableArray array];
    [self.favoriteCategories addObjectsFromArray:@[@"Concerts", @"Comedy & Theatre"]];
    self.favoriteCategory = [self.favoriteCategories firstObject];
    
    return self;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    collectionView.allowsMultipleSelection = self.multipleSelection;
    
    CategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell"
                                                                   forIndexPath:indexPath];
    NSDictionary *data;
    NSUInteger index = indexPath.row;
    DataManager *manager = [DataManager shared];
    if (self.multipleSelection) {
        data = [manager allCategories][index];
    } else {
        NSString *catName = self.favoriteCategories[index];
        data = [manager dataByCategoryName:catName];
    }
    
    [cell buildWithData:data];
    
    if (self.multipleSelection) {
        cell.selected = [self.favoriteCategories containsObject:data[@"name"]];
    } else {
        cell.selected = [self.favoriteCategory isEqualToString:data[@"name"]];
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
    return self.multipleSelection ? [[DataManager shared] allCategories].count : self.favoriteCategories.count;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.favoriteCategories.count > 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell *cell = (CategoryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.favoriteCategory = cell.name;
    
    if (self.multipleSelection) {
        [self addCategoryToFavorites:cell.name];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell *cell = (CategoryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([self.favoriteCategory isEqualToString:cell.name]) {
        self.favoriteCategory = [self.favoriteCategories firstObject];
    }
    
    if (self.multipleSelection) {
        [self.favoriteCategories removeObject:cell.name];
    }
}

#pragma mark - Setters

- (void)setMultipleSelection:(BOOL)multipleSelection {
    _multipleSelection = multipleSelection;
    self.collectionView.allowsMultipleSelection = self.multipleSelection;
    [self.collectionView reloadData];
}

- (void)addFavoriteCategory:(NSString *)category {
    if ([self.favoriteCategories containsObject:category]) {
        return;
    }
    
    [self.favoriteCategories addObject:category];
    [self.collectionView reloadData];
}

- (void)removeFavoriteCategory:(NSString *)category {
    [self.favoriteCategories removeObject:category];
    [self.collectionView reloadData];
}

- (void)useAllCategories {
    NSArray *cats = [[DataManager shared] allCategories];
    for (NSDictionary *dict in cats) {
        NSString *name = dict[@"name"];
        if ([self.favoriteCategories containsObject:name]) {
            continue;
        }
        
        [self addCategoryToFavorites:name];
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

- (void)addCategoryToFavorites:(NSString *)catName {
    [self.favoriteCategories addObject:catName];
    DataManager *manager = [DataManager shared];
    
    NSArray *sorted = [self.favoriteCategories sortedArrayUsingComparator: ^(NSString *string1, NSString *string2) {
        NSInteger first = [manager categoryIndexByName:string1];
        NSInteger second = [manager categoryIndexByName:string2];
        
        if (first < second) {
            return NSOrderedAscending;
        } else if (first > second) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    self.favoriteCategories = [sorted mutableCopy];
}

@end
