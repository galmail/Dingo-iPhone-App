//
//  UIImage+Overlay.h
//  Dingo
//
//  Created by logan on 6/16/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@interface UIImage (Overlay)

- (UIImage *)imageWithColor:(UIColor *)color1;
- (UIImage *)blurredImageWithRadius:(CGFloat)radius;

@end
