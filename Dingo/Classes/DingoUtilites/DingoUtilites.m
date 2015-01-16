//
//  DingoConstants.m
//  Dingo
//
//  Created by logan on 6/4/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DingoUtilites.h"

@implementation DingoUtilites

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return dateFormatter;
}

+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit
                startDate:&fromDate
                 interval:NULL
                  forDate:dt1];
    
    [calendar rangeOfUnit:NSDayCalendarUnit
                startDate:&toDate
                 interval:NULL
                  forDate:dt2];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate
                                                 toDate:toDate
                                                options:0];
    return [difference day];
}

+ (NSString *)eventFormattedDate:(NSDate *)date {
    
    if (!date) {
        return nil;
    }
    
    switch ([DingoUtilites daysBetween:[NSDate date] and:date]) {
       // case -2:
       //     return @"Day before yesterday";
            
       // case -1:
       //     return @"Yesterday";
            
        case 0:
            return @"Today";
            
        case 1:
            return @"Tomorrow";
            
        //case 2:
        //    return @"Day after tomorrow";
            
        default: {
            NSDateFormatter *formatter = [DingoUtilites dateFormatter];
            [formatter setDateFormat:@"EEEE d"];
            NSString *result = [formatter stringFromDate:date];
            
            result = [result stringByAppendingString:[DingoUtilites suffixForDayInDate:date]];
            
            [formatter setDateFormat:@" MMMM"];
            return [result stringByAppendingString:[formatter stringFromDate:date]];
        }
    }
}

+ (NSString *)suffixForDayInDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger day = [[calendar components:NSDayCalendarUnit fromDate:date] day];
    if (day >= 11 && day <= 13) {
        return @"th";
    } else if (day % 10 == 1) {
        return @"st";
    } else if (day % 10 == 2) {
        return @"nd";
    } else if (day % 10 == 3) {
        return @"rd";
    } else {
        return @"th";
    }
}

@end