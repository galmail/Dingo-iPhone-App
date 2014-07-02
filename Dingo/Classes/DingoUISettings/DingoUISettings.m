//
//  DingoUISettings.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DingoUISettings.h"

@implementation DingoUISettings

+ (UIColor *)titleBackgroundColor {
    return [UIColor colorWithRed:61. / 255
                           green:144. / 255
                            blue:172. / 255
                           alpha:1];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:63. / 255
                           green:153. / 255
                            blue:187. / 255
                           alpha:1];
}

+ (UIColor *)foregroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)unimportantItemColor {
    static const CGFloat grayColor = 153. / 255;
    return [UIColor colorWithRed:grayColor
                           green:grayColor
                            blue:grayColor
                           alpha:1];
}

+ (UIColor *)makeHighLightedColorByColor:(UIColor *)color {
    const CGFloat *colors = CGColorGetComponents(color.CGColor);
    static const CGFloat lighterFactor = 1.2;
    return [UIColor colorWithRed:colors[0] * lighterFactor
                           green:colors[1] * lighterFactor
                            blue:colors[2] * lighterFactor
                           alpha:colors[3] * lighterFactor];
}

@end
