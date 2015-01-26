//
//  NSString+DingoFormatting.h
//  Dingo
//
//  Created by Nonnus on 21/01/15.
//  Copyright (c) 2015 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (DingoFormatting)

+ (NSString*)stringWithCurrencyFormattingForPrice:(NSNumber*)price;

@end
