//
//  AFPayuClient.h
//  GroupOnGo
//
//  Created by Richa Goyal on 5/23/14.
//  Copyright (c) 2014 Richa Goyal1. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFPayuClient : AFHTTPClient
+ (AFPayuClient *)sharedClient;
@end
