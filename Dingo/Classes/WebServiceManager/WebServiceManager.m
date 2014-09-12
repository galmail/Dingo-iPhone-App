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
static NSString* geocodeUrl = @"https://maps.googleapis.com/maps/api/geocode/json";
static NSString* placesUrl = @"https://maps.googleapis.com/maps/api/place/autocomplete/json";
static NSString* placeDetailUrl = @"https://maps.googleapis.com/maps/api/place/details/json";

@implementation WebServiceManager

+ (void)imageFromUrl:(NSString *)imageURL completion:( void (^) (id response, NSError *error))handler {

    NSMutableURLRequest *request = [self requestForGetURL:imageURL withParams:nil];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler(data, error);
        });
        
    });
    
}

+ (void)addressToLocation:(NSString *)address completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetURL:geocodeUrl withParams:[NSString stringWithFormat:@"address=%@", address]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });

}

+ (void)fetchLocations:(NSString *)location completion:(void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetURL:placesUrl withParams:[NSString stringWithFormat:@"input=%@&sensor=true&key=%@", [location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"AIzaSyCALgR21D52FM31HEtwP_5m4WsZVRdwJl4"]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
    
}


+ (void)fetchLocationDetails:(NSString *)placeID completion:(void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetURL:placeDetailUrl withParams:[NSString stringWithFormat:@"placeid=%@&key=%@", placeID, @"AIzaSyCALgR21D52FM31HEtwP_5m4WsZVRdwJl4"]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
    
}

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
    
    NSMutableURLRequest *request = [self requestForGetMethod:@"events" withParams:[params urlEncodedString]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)tickets:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForGetMethod:@"tickets" withParams:[params urlEncodedString]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)searchEvents:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler{
    NSMutableURLRequest *request = [self requestForGetMethod:@"events" withParams:[params urlEncodedString]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)createEvent:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = nil;
    
    if ([params[@"image"] isKindOfClass:[NSData class]]) {
        request = [self requestForPostMethod:@"events" withParams:params withAttachements:@[@{@"data":params[@"image"], @"name":@"photo", @"fileName" : [NSString stringWithFormat:@"event_%@", [NSDate date]]}]];
    } else {
        request = [self requestForPostMethod:@"events" withParams:[params urlEncodedString]];
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)createTicket:(NSDictionary *)params photos:(NSArray*)photos completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = nil;
    if (photos.count > 0) {
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        for (int i = 0; i< photos.count ; i++) {
            
            [attachments addObject:@{@"data": UIImagePNGRepresentation(photos[i]), @"name": [NSString stringWithFormat:@"photo%d", i+1], @"fileName" : [NSString stringWithFormat:@"ticketPhoto_%@", [NSDate date]]}];
        }
        
        request = [self requestForPostMethod:@"tickets" withParams:params withAttachements:attachments];
    } else {
        request = [self requestForPostMethod:@"tickets" withParams:[params urlEncodedString]];
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)updateTicket:(NSDictionary *)params photos:(NSArray*)photos completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = nil;
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    for (int i = 0; i< photos.count ; i++) {
        
        [attachments addObject:@{@"data": UIImagePNGRepresentation(photos[i]), @"name": [NSString stringWithFormat:@"photo%d", i+1], @"fileName" : [NSString stringWithFormat:@"ticketPhoto_%@", [NSDate date]]}];
    }
    
    request = [self requestForPutMethod:[NSString stringWithFormat:@"tickets/%@", params[@"ticket_id"]] withParams:params withAttachements:attachments];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"ddd %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

+ (void)registerDevice:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
   
    NSMutableURLRequest *request = [self requestForPostMethod:@"devices" withParams:[params urlEncodedString]];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });

}

+ (void)updateProfile:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForPostMethod:@"users" withParams:[params urlEncodedString]];
   
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
    
}

+ (void)sendOffer:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
            
    NSMutableURLRequest *request = [self requestForPostMethod:@"offers" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
    
}

+ (void)receiveOffers:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetMethod:@"offers" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
    
}

+ (void)receiveMessages:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSDictionary* params1 = @{@"conversations": @"true"};
    params = params1;
    NSMutableURLRequest *request = [self requestForGetMethod:@"messages" withParams:[params urlEncodedString]];
    
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
//    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForGetMethod:(NSString *)method withParams:(NSString *)params {
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", apiUrl, method, params];
    if (params.length == 0) {
        url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    }
//    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[AppManager sharedManager].token forHTTPHeaderField:@"X-User-Token"];
    [request setValue:[AppManager sharedManager].userInfo[@"email"] forHTTPHeaderField:@"X-User-Email"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForPostMethod:(NSString *)method withParams:(NSString *)params {
    
    NSString* url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    
    if (params.length > 0) {
        NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:postData];
    }
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:[AppManager sharedManager].token forHTTPHeaderField:@"X-User-Token"];
    [request setValue:[AppManager sharedManager].userInfo[@"email"] forHTTPHeaderField:@"X-User-Email"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForPostMethod:(NSString *)method withParams:(NSDictionary *)params  withAttachements:(NSArray *)attachments {
    
    NSString* url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
 
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // attachments
    for (NSDictionary *attachment in attachments) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"%@\"; filename=\"%@.png\"\r\n", attachment[@"name"], attachment[@"fileName"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:attachment[@"data"]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // parameters
    for (NSString *key in [params allKeys]) {
        
        if ([params[key] length] == 0 || ![params[key] isKindOfClass:[NSString class]]) {
            continue;
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[params[key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    [request setValue:[AppManager sharedManager].token forHTTPHeaderField:@"X-User-Token"];
    [request setValue:[AppManager sharedManager].userInfo[@"email"] forHTTPHeaderField:@"X-User-Email"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForPutMethod:(NSString *)method withParams:(NSDictionary *)params  withAttachements:(NSArray *)attachments {
    
    NSString* url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    
    [request setHTTPMethod:@"PUT"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // attachments
    for (NSDictionary *attachment in attachments) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"%@\"; filename=\"%@.png\"\r\n", attachment[@"name"], attachment[@"fileName"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:attachment[@"data"]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // parameters
    for (NSString *key in [params allKeys]) {
        
        if ([params[key] length] == 0 || ![params[key] isKindOfClass:[NSString class]]) {
            continue;
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[params[key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    [request setValue:[AppManager sharedManager].token forHTTPHeaderField:@"X-User-Token"];
    [request setValue:[AppManager sharedManager].userInfo[@"email"] forHTTPHeaderField:@"X-User-Email"];
    
    return request;
}

+ (void)messages:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForGetMethod:@"messages" withParams:[params urlEncodedString]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            handler([data objectFromJSONData], error);
        });
        
    });
}

@end
