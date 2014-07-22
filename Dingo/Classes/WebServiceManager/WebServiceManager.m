//
//  WebServiceManager.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/16/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "WebServiceManager.h"
#import "JSON.h"
#import "NSDictionary+UrlEncoding.h"
#import "AppManager.h"

static NSString* apiUrl = @"http://dingoapp.herokuapp.com/api/v1/";
static NSString* signUpUrl = @"http://dingoapp.herokuapp.com/users/sign_up";
static NSString* signInUrl = @"http://dingoapp.herokuapp.com/users/sign_in";

@implementation WebServiceManager

+ (void)signUp:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {

    NSMutableURLRequest *request = [self requestForGetURL:signUpUrl withParams:[params urlEncodedString]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
    
}

+ (void)signIn:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetURL:signInUrl withParams:[params urlEncodedString]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)categories:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetMethod:@"categories" withParams:nil];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)events:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetMethod:@"events" withParams:nil];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

#pragma mark - requests

+ (NSMutableURLRequest *) requestForGetURL:(NSString *)url withParams:(NSString *)params {

    if (params.length > 0) {
        url = [NSString stringWithFormat:@"%@?%@", url, params];
    }
    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForGetMethod:(NSString *)method withParams:(NSString *)params {
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", apiUrl, method, params];
    if (params.length == 0) {
        url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    }
    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[AppManager sharedManager].token forHTTPHeaderField:@"X-User-Token"];
    [request setValue:[AppManager sharedManager].userInfo[@"email"] forHTTPHeaderField:@"X-User-Email"];
    
    return request;
}


@end
