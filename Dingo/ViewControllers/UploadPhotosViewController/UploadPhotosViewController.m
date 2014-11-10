//
//  UploadPhotosViewController.m
//  Dingo
//
//  Created by logan on 6/19/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "UploadPhotosViewController.h"

#import "TicketPhotoCell.h"

static const NSUInteger mainPhotoCellIndex = 2;
static const NSUInteger mainPhotoDownloadedCellIndex = 3;

@interface UploadPhotosViewController () <UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, TicketsPhotoCellDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell *mainPhotoCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *downloadedMainPhotoCell;
@property (nonatomic, weak) IBOutlet UIImageView *mainPhotoImageView;
@property (nonatomic, weak) IBOutlet UICollectionView *otherPhotosCollectionView;
@property (nonatomic) BOOL isMainPhotoLoading;

@end

@implementation UploadPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.photos) {
        self.photos = [NSMutableArray new];
    }
    
    self.mainPhotoImageView.image = self.mainPhoto;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.photos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"AddPhotoCell"
                                                         forIndexPath:indexPath];
    }
    
    TicketPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LoadedPhotoCell"
                                                                      forIndexPath:indexPath];
    
    cell.ticketPhoto = self.photos[indexPath.row - 1];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case mainPhotoCellIndex:
            if (self.mainPhotoImageView.image) {
                return 0;
            }
            
            //temp remove when want add main photo
            return 0;
            break;
            
        case mainPhotoDownloadedCellIndex:
            if (!self.mainPhotoImageView.image) {
                return 0;
            }
            
            //temp remove when want add main photo
            return 0;
            
            break;
        default:
            NSLog(@"Default");
            break;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (self.isMainPhotoLoading) {
        self.mainPhoto = self.mainPhotoImageView.image = image;
        [self.tableView reloadData];
    } else {
        [self.photos insertObject:image atIndex:0];
        [self.otherPhotosCollectionView reloadData];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 1) {
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    switch (buttonIndex) {
        case 0:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIActions

- (IBAction)addMainPhoto {
    self.isMainPhotoLoading = YES;
    [self showActionSheet];
}

- (IBAction)addOtherPhoto {
    self.isMainPhotoLoading = NO;
    [self showActionSheet];
}

- (IBAction)removeMainPhoto {
    self.mainPhotoImageView.image = nil;
    self.mainPhoto = nil;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)doneButtonTouched {
    [self back];
}

#pragma mark - Navigation

- (IBAction)back {
    if (self.delegate) {
        [self.delegate displayPhotos:[self.photos copy] mainPhoto:self.mainPhoto];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TicketPhotoCellDelegate

- (void)removePhotoCell:(id)cell {
    NSIndexPath *path = [self.otherPhotosCollectionView indexPathForCell:cell];
    NSUInteger cellIndex = path.row;
    [self.otherPhotosCollectionView performBatchUpdates:^{
        [self.photos removeObjectAtIndex:cellIndex - 1];
        [self.otherPhotosCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:path]];
        
    }
                                             completion:nil];
}

#pragma mark - Private

- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take photo", @"Choose From Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

@end
