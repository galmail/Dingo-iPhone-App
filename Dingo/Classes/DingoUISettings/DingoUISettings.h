//
//  DingoUISettings.h
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface DingoUISettings : NSObject

+ (UIColor *)titleBackgroundColor;
+ (UIColor *)backgroundColor;
+ (UIColor *)foregroundColor;
+ (UIColor *)unimportantItemColor;
+ (UIColor *)makeHighLightedColorByColor:(UIColor *)color;

+ (UIFont *)fontWithSize:(CGFloat)fontSize;
+ (UIFont *)boldFontWithSize:(CGFloat)fontSize;
+ (UIFont *)lightFontWithSize:(CGFloat)fontSize;

@end
