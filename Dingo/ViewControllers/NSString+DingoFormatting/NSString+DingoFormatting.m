//
//  NSString+DingoFormatting.m
//  Dingo
//
//  Created by Nonnus on 21/01/15.
//  Copyright (c) 2015 Dingo. All rights reserved.
//

#import "NSString+DingoFormatting.h"

@implementation NSString (DingoFormatting)

+ (NSString*)stringWithCurrencyFormattingForPrice:(NSNumber*)price {
	if (price.floatValue > price.intValue) {
		//faceValue is not whole number, set the textfield with 2 decimal points
		return [NSString stringWithFormat:@"%.2f", price.floatValue];
	} else {
		//we could leave the field as it is, but if someone enters 50. is nice to clean it :)
		return [NSString stringWithFormat:@"%i", price.intValue];
	}
}

@end
