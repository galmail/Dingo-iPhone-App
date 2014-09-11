//
//  ImagesViewController.m
//  Dingo
//
//  Created by Asatur Galstyan on 9/11/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ImagesViewController.h"
#import "TicketPhotoCell.h"

static const NSUInteger photosPerPage = 1;

@interface ImagesViewController () {
  
    __weak IBOutlet UICollectionView *photosCollectionView;
    __weak IBOutlet UIPageControl *pageControl;
}

@end

@implementation ImagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updatePageControl];
    photosCollectionView.collectionViewLayout = [self collectionViewFlowLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UICollectionViewDataSource

- (UICollectionViewFlowLayout *)collectionViewFlowLayout
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = CGSizeMake(270, 235);
    flowLayout.sectionInset = UIEdgeInsetsMake(25, 25, 25, 25);
    flowLayout.minimumInteritemSpacing = 0.0f;
    flowLayout.minimumLineSpacing = 50.0f;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return flowLayout;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TicketPhotoCell *cell = [photosCollectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"
                                                                           forIndexPath:indexPath];
    cell.ticketPhoto = self.photos[indexPath.row];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageControl.currentPage = ceilf(scrollView.contentOffset.x / scrollView.frame.size.width);
}

- (void)updatePageControl {
    pageControl.numberOfPages = ceilf((float)self.photos.count / photosPerPage);
}


@end
