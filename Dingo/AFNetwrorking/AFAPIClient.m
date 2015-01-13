//
//  AFAPIClient.h
//  Talent
//
//  Created by Richa Goyal on 10/10/13.
//  Copyright (c) 2013 Richa Goyal All rights reserved.
//

#import "AFAPIClient.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"


@implementation AFAPIClient
+ (AFAPIClient *)sharedClient {
    
    static AFAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFAPIClient alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
   
     self.parameterEncoding=AFJSONParameterEncoding;
       [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"X-User-Token" value:([AppManager sharedManager].token != nil?[AppManager sharedManager].token:[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"])];
    [self setDefaultHeader:@"X-User-Email" value:([AppManager sharedManager].userInfo[@"email"]!= nil?[AppManager sharedManager].userInfo[@"email"]:[[NSUserDefaults standardUserDefaults] objectForKey:@"users_email"])];
    
    
    
    return self;
}


@end
