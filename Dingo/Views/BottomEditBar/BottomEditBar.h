//
//  BottomEditBar.h
//  Dingo
//
//  Created by Asatur Galstyan on 8/30/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BottomBarDelegate <NSObject>

@optional
- (void)editListing;
- (void)deleteListing;

@end

@interface BottomEditBar : UIView
@property(weak,nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic, assign) id<BottomBarDelegate> delegate;

@end
