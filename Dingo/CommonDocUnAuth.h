//
//  CommonDocUnAuth.h
//  GroupOnGo
//
//  Created by Richa Goyal on 6/23/14.
//  Copyright (c) 2014 Richa Goyal1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "AFAPIClient.h"

@interface CommonDocUnAuth : NSObject
+ (CommonDocUnAuth *)sharedDocument;
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
