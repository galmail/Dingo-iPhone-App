//
//  NSDictionary+UrlEncoding.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/16/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "NSDictionary+UrlEncoding.h"

// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (__bridge CFStringRef) string,
                                                                                                    NULL,
                                                                                                    CFSTR("!*'();:&=+$,/?%#[]\" "),
                                                                                                    kCFStringEncodingUTF8));
    return escapedString;
}


@implementation NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        if ([key rangeOfString:@"[]"].location != NSNotFound ) {
            NSArray *values = [value componentsSeparatedByString:@","];
            for (NSString *val in values) {
                NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(val)];
                [parts addObject: part];
            }
        } else {
            NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
            [parts addObject: part];

        }
    }
    return [parts componentsJoinedByString: @"&"];
}


@end
