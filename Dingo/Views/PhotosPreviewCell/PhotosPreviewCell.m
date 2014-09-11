//
//  PhotosPreviewCell.m
//  Dingo
//
//  Created by logan on 6/20/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "PhotosPreviewCell.h"

#import "DataManager.h"
#import "TicketPhotoCell.h"

static const NSUInteger photosPerPage = 2;

@interface PhotosPreviewCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end

@implementation PhotosPreviewCell

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"PhotosPreviewCell"
                                  owner:self
                                options:nil];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TicketPhotoCell"
                                                    bundle:nil]
          forCellWithReuseIdentifier:@"PhotoCell"];
    
    self.frame = self.view.frame;
    [self addSubview:self.view];
    
    [self loadPhotos];
    [self updatePageControl];
    
    return self;
}

#pragma mark - Setters

- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    [self.collectionView reloadData];
    [self updatePageControl];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TicketPhotoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"
                                                                           forIndexPath:indexPath];
    cell.ticketPhoto = self.photos[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.parentViewController performSegueWithIdentifier:@"ImagesSegue" sender:self.parentViewController];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = ceilf(scrollView.contentOffset.x / scrollView.frame.size.width);
}

#pragma mark - Private

- (void)updatePageControl {
    self.pageControl.numberOfPages = ceilf((float)self.photos.count / photosPerPage);
}

- (void)loadPhotos {
    self.photos = [NSMutableArray array];
    
    return;
    NSArray *cats = [[DataManager shared] allCategories];
    for (EventCategory *category in cats) {
        [self.photos addObject:[UIImage imageWithData:category.thumb]];
    }
}

@end
