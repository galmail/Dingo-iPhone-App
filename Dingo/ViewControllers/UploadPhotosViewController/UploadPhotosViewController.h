//
//  UploadPhotosViewController.h
//  Dingo
//
//  Created by logan on 6/19/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@protocol UploadPhotosVCDelegate

- (void)displayPhotos:(NSArray *)array mainPhoto:(UIImage *)mainPhoto;

@end

@interface UploadPhotosViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) UIImage *mainPhoto;
@property (nonatomic, weak) id <UploadPhotosVCDelegate> delegate;

@end
