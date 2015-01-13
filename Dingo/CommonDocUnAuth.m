//
//  CommonDocUnAuth.m
//  GroupOnGo
//
//  Created by Richa Goyal on 6/23/14.
//  Copyright (c) 2014 Richa Goyal1. All rights reserved.
//

#import "CommonDocUnAuth.h"

@implementation CommonDocUnAuth
+ (CommonDocUnAuth *)sharedDocument {
    
    static CommonDocUnAuth *_sharedDocument = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDocument = [[CommonDocUnAuth alloc] init];
    });
    return _sharedDocument;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    
    [[AFAPIClient sharedClient] getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
           success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure)
            failure(operation, error);
    }];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[AFAPIClient sharedClient] postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure)
            failure(operation, error);
    }];
    
}


@end
