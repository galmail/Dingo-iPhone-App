//
//  ZSLoadingView.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/28/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ZSLoadingView.h"

@interface ZSLoadingView () {
    UIView *loadingBGView;
    UIActivityIndicatorView *activityIndicator;
    UILabel *lblText;
}

@end

@implementation ZSLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithLabel:(NSString*)label {
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
        
        loadingBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        loadingBGView.backgroundColor = [DingoUISettings titleBackgroundColor];
        loadingBGView.alpha = 0.90;
        loadingBGView.center = self.center;
        loadingBGView.layer.cornerRadius = 5;
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = CGPointMake(loadingBGView.frame.size.width/2,loadingBGView.frame.size.height/2);
        [activityIndicator startAnimating];
        
        [loadingBGView addSubview:activityIndicator];
        
        lblText = [[UILabel alloc] initWithFrame:CGRectMake(0, loadingBGView.frame.size.height - 40, loadingBGView.frame.size.width, 30)];
        lblText.textColor = [UIColor whiteColor];
        lblText.textAlignment = NSTextAlignmentCenter;
        lblText.text = label;
        
        [loadingBGView addSubview:lblText];
        
        [self addSubview:loadingBGView];
        
    }
    return self;
}

- (void)show {
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    
    [window addSubview:self];
    [window bringSubviewToFront:self];
}

- (void)hide {
    [self removeFromSuperview];
    
}


@end
