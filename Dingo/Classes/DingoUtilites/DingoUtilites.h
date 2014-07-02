//
//  DingoConstants.h
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@interface DingoUtilites : NSObject

+ (NSDateFormatter *)dateFormatter;
+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
+ (NSString *)eventFormattedDate:(NSDate *)date;
+ (NSString *)suffixForDayInDate:(NSDate *)date;

@end