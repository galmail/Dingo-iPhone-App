//
//  AFPayuClient.m
//  GroupOnGo
//
//  Created by Richa Goyal on 5/23/14.
//  Copyright (c) 2014 Richa Goyal1. All rights reserved.
//

#import "AFPayuClient.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"


@implementation AFPayuClient
+ (AFPayuClient *)sharedClient {
    
    static AFPayuClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFPayuClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    });
    return _sharedClient;
}

//- (id)initWithBaseURL:(NSURL *)url {
//    self = [super initWithBaseURL:url];
//    if (!self) {
//        return nil;
//    }
//    
//    self.parameterEncoding=AFJSONParameterEncoding;
//    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
//    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
//    [self setDefaultHeader:@"Accept" value:@"application/json"];
//    
//    return self;
//}



@end
