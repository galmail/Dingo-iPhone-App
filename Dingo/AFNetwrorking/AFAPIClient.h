//
//  AFAPIClient.h
//  Talent
//
//  Created by Richa Goyal on 10/10/13.
//  Copyright (c) 2013 Richa Goyal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
@class AFHTTPClient;
@interface AFAPIClient : AFHTTPClient
{
    
}
+ (AFAPIClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;
@end
