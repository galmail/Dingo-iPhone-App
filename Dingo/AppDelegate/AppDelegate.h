//
//  AppDelegate.h
//  Dingo
//
//  Created by logan on 5/30/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AppsFlyerTracker.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property  (strong,nonatomic) UIView *viewNotification;

-(void)showNotiFicationView:(NSDictionary *)payLoad;
@end

extern NSString *lastChatUser;