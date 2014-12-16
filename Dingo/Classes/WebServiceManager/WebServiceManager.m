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
#import <FacebookSDK/FacebookSDK.h>
#import "UIDevice+Additions.h"

#ifdef kProductionMode
static NSString* apiUrl = kProductionAPI;
static NSString* signUpUrl = kProductionSignUpUrl;
static NSString* signInUrl = kProductionSignInUrl;
#else
static NSString* apiUrl = kDevelopmentAPI;
static NSString* signUpUrl = kDevelopmentSignUpUrl;
static NSString* signInUrl = kDevelopmentSignInUrl;
#endif

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
    
    NSDictionary *params = @{@"address":address};
    
    NSMutableURLRequest *request = [self requestForGetURL:geocodeUrl withParams:[params urlEncodedString]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
                handler(nil,error);
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
                handler(nil,error);
            } else {
                handler([data objectFromJSONData], error);
            }
        });
    });
}

+ (void)signInWithFBAndUpdate:(BOOL)update completion:( void (^) (id response, NSError *error))handler {
    
    [FBSession openActiveSessionWithReadPermissions:@[@"email", @"user_birthday", @"user_location", @"user_friends"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      
                                      if (error) {
                                          
                                          [AppManager showAlert:[error localizedDescription]];
                                          
                                          handler(nil, error);

                                      } else {
                                          if (state == FBSessionStateOpen) {
                                              NSLog(@"start");
                                              
                                              FBRequest *request = [FBRequest requestForMe];
                                              [request.parameters setValue:@"id,name,first_name,last_name,email,picture,birthday,location" forKey:@"fields"];
                                              
                                              [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
                                                  if (user) {
                                                      
                                                      NSString *birtday = nil;
                                                      if(user.birthday.length > 0) {
                                                          // change date format from MM/DD/YYYY to DD/MM/YYYY
                                                          NSArray *dateArray = [user.birthday componentsSeparatedByString:@"/"];
                                                          dateArray = @[ dateArray[1], dateArray[0], dateArray[2]];
                                                          birtday = [dateArray componentsJoinedByString:@"/"];
                                                      }
                                                      
                                                      NSDictionary *params = @{ @"name" : user.first_name,
                                                                                @"surname": user.last_name,
                                                                                @"email" : user[@"email"],
                                                                                @"password" : [NSString stringWithFormat:@"fb%@", user.objectID],
                                                                                @"fb_id" : user.objectID,
                                                                                @"date_of_birth": birtday.length > 0 ? birtday : @"",
                                                                                @"city": user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London",
                                                                                @"photo_url": [NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID],//user[@"picture"][@"data"][@"url"],
                                                                                @"device_uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
                                                                                @"device_brand":@"Apple",
                                                                                @"device_model": [[UIDevice currentDevice] platformString],
                                                                                @"device_os":[[UIDevice currentDevice] systemVersion],
                                                                                @"device_location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ]
                                                                                };
                                                      
                                                      if (update) {
                                                          NSLog(@"update");

                                                          [WebServiceManager updateProfile:params completion:^(id response, NSError *error) {
                                                              if (response) {
                                                                  [AppManager sharedManager].token = response[@"authentication_token"];
                                                                  
                                                                  [AppManager sharedManager].userInfo = [
                                                                                                         @{@"id":response[@"id"],
                                                                                                           @"email":user[@"email"],
                                                                                                           @"name": user.first_name,
                                                                                                           @"surname": response[@"surname"],
                                                                                                           @"allow_dingo_emails": response[@"allow_dingo_emails"],
                                                                                                           @"allow_push_notifications":  response[@"allow_push_notifications"],
                                                                                                           @"fb_id":user.objectID,
                                                                                                           @"photo_url":[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID],
                                                                                                           @"city" : user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London",
                                                                                                           @"paypal_account":(![response[@"paypal_account"] isKindOfClass:[NSNull class]] && [response[@"paypal_account"] length]) ? response[@"paypal_account"] : @""} mutableCopy];
                                                              }
                                                              handler(response, error);
                                                          }];
                                                          
                                                      } else {
                                                          NSLog(@"not update");
                                                          [WebServiceManager signUp:params completion:^(id response, NSError *error) {
                                                              NSLog(@"signUp response %@", response);
                                                              if (error) {
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                  [alert show];
                                                                  
                                                                  handler(nil, error);
                                                              } else {
                                                                  if (response) {
                                                                      
                                                                      if (response[@"authentication_token"]) {
                                                                          [AppManager sharedManager].token = response[@"authentication_token"];
                                                                          
                                                                          [AppManager sharedManager].userInfo = [@{ @"id":response[@"id"], @"fb_id" : user.objectID, @"email":user[@"email"], @"name": user.first_name, @"photo_url":[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID], @"city":user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London",
                                                                                                                    @"paypal_account": (![response[@"paypal_account"] isKindOfClass:[NSNull class]] && [response[@"paypal_account"] length]) ? response[@"paypal_account"] : @""} mutableCopy];
                                                                          
                                                                          handler(response, nil);
                                                                      } else {
                                                                          
                                                                          // login
                                                                          NSDictionary *params = @{ @"email" : user[@"email"]/*@"pierrot.lechot@gmail.com"*/,
                                                                                                    @"password" : [NSString stringWithFormat:@"fb%@", user.objectID]/*@"fb10203955157912595"*/
                                                                                                    };
                                                                          
                                                                          [WebServiceManager signIn:params completion:^(id response, NSError *error) {
                                                                              NSLog(@"login response %@", response);
                                                                              if (error ) {
                                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                  [alert show];
                                                                                  handler(nil,error);
                                                                              } else {
                                                                                  
                                                                                  if (response) {
                                                                                      
                                                                                      if ([response[@"success"] boolValue]) {
                                                                                          [AppManager sharedManager].token = response[@"auth_token"];
                                                                                          
                                                                                          [AppManager sharedManager].userInfo = [
                                                                                                                                 @{@"id":response[@"id"],
                                                                                                                                   @"email":user[@"email"],
                                                                                                                                   @"name": user.first_name,
                                                                                                                                   @"surname": response[@"surname"],
                                                                                                                                   @"allow_dingo_emails": response[@"allow_dingo_emails"],
                                                                                                                                   @"allow_push_notifications":  response[@"allow_push_notifications"],
                                                                                                                                   @"fb_id":user.objectID,
                                                                                                                                   @"photo_url":[NSString stringWithFormat:@"http://graph.facebook.com/v2.0/%@/picture?redirect=1&height=200&type=normal&width=200",user.objectID],
                                                                                                                                   @"city" : user.location ? [[user.location.name componentsSeparatedByString:@","] firstObject] : @"London",
                                                                                                                                   @"paypal_account":(![response[@"paypal_account"] isKindOfClass:[NSNull class]] && [response[@"paypal_account"] length]) ? response[@"paypal_account"] : @""} mutableCopy];
                                                                                          
                                                                                          if ([AppManager sharedManager].deviceToken.length > 0) {
                                                                                              // register device
                                                                                              NSDictionary *deviceParams = @{ @"uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
                                                                                                                              @"brand":@"Apple",
                                                                                                                              @"model": [[UIDevice currentDevice] platformString],
                                                                                                                              @"os":[[UIDevice currentDevice] systemVersion],
                                                                                                                              @"app_version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                                                                                                                              @"location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ]
                                                                                                                              };
                                                                                              
                                                                                              [WebServiceManager registerDevice:deviceParams completion:^(id response, NSError *error) {
                                                                                                  handler(response, nil);
                                                                                              }];
                                                                                          } else {
                                                                                              handler(response, nil);
                                                                                          }
                                                                                          
                                                                                      } else {
                                                                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                          [alert show];
                                                                                          
                                                                                          handler(nil, nil);
                                                                                      }
                                                                                      
                                                                                  } else {
                                                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign in, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                      [alert show];
                                                                                      
                                                                                      handler(nil, nil);
                                                                                  }
                                                                              }
                                                                          }];
                                                                          
                                                                      }
                                                                      
                                                                  } else {
                                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"Unable to sign up, please try later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                      [alert show];
                                                                      
                                                                      handler(nil, nil);
                                                                  }
                                                                  
                                                                  
                                                              }
                                                              
                                                              
                                                          }];
                                                      }
                                                  } else {
                                                      handler(nil, nil);
                                                  }
                                                  
                                              }];
                                          } else {
                                              handler(nil, nil);
                                          }
                                      }
                                      
                                  }];
}

+ (void)categories:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetMethod:@"categories" withParams:nil];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
                handler(nil,error);
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
                handler(nil,error);
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
                handler(nil,error);
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
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
        NSLog(@"createEvent %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                
                [self genericErrorWithMessage:error];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
    });
}

+ (void)createTicket:(NSDictionary *)params photos:(NSArray*)photos completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = nil;
    if (photos.count > 0) {
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        for (int i = 0; i< photos.count ; i++) {
            NSData *imageData = UIImageJPEGRepresentation(photos[i], 0.2);
            
            [attachments addObject:@{@"data": imageData, @"name": [NSString stringWithFormat:@"photo%d", i+1], @"fileName" : [NSString stringWithFormat:@"ticketPhoto_%@", [NSDate date]]}];
        }

        request = [self requestForPostMethod:@"tickets" withParams:params withAttachements:attachments];
    } else {
        request = [self requestForPostMethod:@"tickets" withParams:[params urlEncodedString]];
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"createTicket %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericErrorWithMessage:error];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
    });
}

+ (void)updateTicket:(NSDictionary *)params photos:(NSArray*)photos completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = nil;
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    for (int i = 0; i< photos.count ; i++) {
        
        [attachments addObject:@{@"data": UIImageJPEGRepresentation(photos[i],0.2), @"name": [NSString stringWithFormat:@"photo%d", i+1], @"fileName" : [NSString stringWithFormat:@"ticketPhoto_%@", [NSDate date]]}];
    }
    
    request = [self requestForPutMethod:[NSString stringWithFormat:@"tickets/%@", params[@"ticket_id"]] withParams:params withAttachements:attachments];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"updateTicket %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
                handler(nil, error);
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
                handler(nil,error);
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

#pragma mark Offers

+ (void)sendOffer:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
            
    NSMutableURLRequest *request = [self requestForPostMethod:@"offers" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

+ (void)replyOffer:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForPutMethod:[NSString stringWithFormat:@"offers/%@", params[@"offerID"]] withParams:params withAttachements:nil];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
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
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

+ (void)makeOrder:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForPostMethod:@"orders" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

+ (void)payPalSuccess:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForPostMethod:@"paypal/success" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
    });
}


#pragma mark Messages

+ (void)receiveMessages:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForGetMethod:@"messages" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"receiveMessages %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

+ (void)sendMessage:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForPostMethod:@"messages" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

+ (void)markAsRead:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForPutMethod:[NSString stringWithFormat:@"messages/%@", params[@"messageID"]] withParams:nil withAttachements:nil];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

#pragma mark Alerts

+ (void)createAlert:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    
    NSMutableURLRequest *request = [self requestForPostMethod:@"alerts" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericErrorWithMessage:error];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

+ (void)userAlerts:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler {
    NSMutableURLRequest *request = [self requestForGetMethod:@"alerts" withParams:[params urlEncodedString]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}


#pragma mark - requests

+ (NSMutableURLRequest *) requestForGetURL:(NSString *)url withParams:(NSString *)params {

    if (params.length > 0) {
        url = [NSString stringWithFormat:@"%@?%@", url, params];
    }
//    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForGetMethod:(NSString *)method withParams:(NSString *)params {
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", apiUrl, method, params];
    if (params.length == 0) {
        url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    }
//    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
    [request setHTTPMethod:@"GET"];
    NSLog(@"token %@", [AppManager sharedManager].token);
    NSLog(@"userInfo email %@", [AppManager sharedManager].userInfo[@"email"]);
    [request setValue:[AppManager sharedManager].token forHTTPHeaderField:@"X-User-Token"];
    [request setValue:[AppManager sharedManager].userInfo[@"email"] forHTTPHeaderField:@"X-User-Email"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForPostMethod:(NSString *)method withParams:(NSString *)params {
    
    NSString* url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
    
    if (params.length > 0) {
        NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:postData];
    }
    
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"token %@", [AppManager sharedManager].token);
    NSLog(@"userInfo email %@", [AppManager sharedManager].userInfo[@"email"]);

    [request setValue:[AppManager sharedManager].token forHTTPHeaderField:@"X-User-Token"];
    [request setValue:[AppManager sharedManager].userInfo[@"email"] forHTTPHeaderField:@"X-User-Email"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForPostMethod:(NSString *)method withParams:(NSDictionary *)params  withAttachements:(NSArray *)attachments {
    
    NSString* url = [NSString stringWithFormat:@"%@%@", apiUrl, method];
    url =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
 
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
    
    [request setHTTPMethod:@"PUT"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // attachments
    if (attachments.count) {
        for (NSDictionary *attachment in attachments) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"%@\"; filename=\"%@.png\"\r\n", attachment[@"name"], attachment[@"fileName"]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:attachment[@"data"]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
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
            if (error != nil) {
                [self genericError];
            } else {
                handler([data objectFromJSONData], error);
            }
        });
        
    });
}

+ (void)genericError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:@"The server is busy, please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (void)genericErrorWithMessage:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
