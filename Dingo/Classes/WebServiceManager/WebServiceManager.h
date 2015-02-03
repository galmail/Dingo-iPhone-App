//
//  WebServiceManager.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/16/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceManager : NSObject

+ (void)imageFromUrl:(NSString *)imageURL completion:( void (^) (id response, NSError *error))handler;

+ (void)signUp:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)signIn:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)signInWithFBAndUpdate:(BOOL)update completion:( void (^) (id response, NSError *error))handler;

+ (void)categories:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)events:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)tickets:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)messages:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)searchEvents:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)createEvent:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)createTicket:(NSDictionary *)params photos:(NSArray*)photos completion:( void (^) (id response, NSError *error))handler;
+ (void)updateTicket:(NSDictionary *)params photos:(NSArray*)photos completion:( void (^) (id response, NSError *error))handler;

+ (void)addressToLocation:(NSString *)address completion:( void (^) (id response, NSError *error))handler;

+ (void)fetchLocations:(NSString *)location completion:(void (^) (id response, NSError *error))handler;
+ (void)fetchLocationDetails:(NSString *)placeID completion:(void (^) (id response, NSError *error))handler;

+ (void)registerDevice:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;

+ (void)sendOffer:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)replyOffer:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)receiveOffers:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;

+ (void)paypalUserInfo:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)makeOrder:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)payPalSuccess:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;

+ (void)receiveMessages:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)sendMessage:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)markAsRead:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;

+ (void)updateProfile:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;

+ (void)createAlert:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;
+ (void)userAlerts:(NSDictionary *)params completion:( void (^) (id response, NSError *error))handler;

+ (void)handleError:(NSError *)error;
+ (void)genericErrorWithMessage:(NSError *)error;
+ (void)genericError;
+ (void)noInternetError;
@end
