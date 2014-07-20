//
//  JSON.h
//  Dingo
//
//  Created by Asatur Galstyan on 4/24/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Deserializing methods

@interface NSString (JSONDeserializing)

- (id)objectFromJSONString;

@end

@interface NSData (JSONDeserializing)

- (id)objectFromJSONData;

@end


#pragma mark Serializing methods

@interface NSString (JSONSerializing)
- (NSData *)JSONData;
- (NSString *)JSONString;
@end

@interface NSArray (JSONSerializing)
- (NSData *)JSONData;
- (NSString *)JSONString;
@end

@interface NSDictionary (JSONSerializing)
- (NSData *)JSONData;
- (NSString *)JSONString;
@end
