//
//  AppDelegate.m
//  Dingo
//
//  Created by logan on 5/30/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "AppDelegate.h"

#import "DingoUISettings.h"

#import <FacebookSDK/FacebookSDK.h>
#import "AppManager.h"
#import "SlidingViewController.h"
#import "HomeTabBarController.h"
#import "DingoNavigationController.h"
#import "UIDevice+Additions.h"
#import "WebServiceManager.h"
#import "PayPalMobile.h"
#import "DataManager.h"
#import "Appirater.h"
#import "Harpy.h"

#import "GAI.h"

@implementation AppDelegate
@synthesize viewNotification;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   
    [Appirater setAppId:@"893538091"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];

    
    [[Harpy sharedInstance] setAppID:@"893538091"];
    [[Harpy sharedInstance] checkVersion];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [DingoUISettings foregroundColor]}
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [DingoUISettings backgroundColor]}
                                             forState:UIControlStateSelected];
    [[UISwitch appearance] setTintColor:[DingoUISettings foregroundColor]];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    } else {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction :kPaypalProductionID,
                                                           PayPalEnvironmentSandbox : kPaypalSendboxID }];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-54649568-2"];

    
    if ([AppManager sharedManager].token) {
        SlidingViewController *viewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
        self.window.rootViewController = viewController;
    }
    application.applicationIconBadgeNumber = 0;
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Show the device token obtained from apple to the log
    NSString *newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [AppManager sharedManager].deviceToken = newToken;
    
    NSLog(@"deviceToken - %@",newToken);
    
    if ([[AppManager sharedManager].deviceToken length]) {
        NSDictionary *params = @{ @"uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
                                  @"brand":@"Apple",
                                  @"model": [[UIDevice currentDevice] platformString],
                                  @"os":[[UIDevice currentDevice] systemVersion],
                                  @"app_version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                                  @"location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ]
                                  };
        [WebServiceManager registerDevice:params completion:^(id response, NSError *error) {
            NSLog(@"registerDevice response - %@", response);
            NSLog(@"registerDevice error - %@", error);
        }];
    }
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self showNotiFicationView];
    }else{
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Dingo" message:@"You received a new message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
    }
    
    
    if ( application.applicationState == UIApplicationStateActive ) {
    
        if ([self.window.rootViewController isKindOfClass:[SlidingViewController class]]){
            SlidingViewController *vc = (SlidingViewController *)self.window.rootViewController;
            
            DingoNavigationController *nc = (DingoNavigationController *)vc.topViewController;
            
            HomeTabBarController *tabBarConroller = (HomeTabBarController *)nc.topViewController;
            [[DataManager shared] fetchMessagesWithCompletion:^(BOOL finished) {
                [tabBarConroller updateMessageCount];
            }];
        }
  
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[AppManager sharedManager] save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    
    [[Harpy sharedInstance] checkVersionDaily];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[AppManager sharedManager] save];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark - custom methods
-(void)showNotiFicationView{
    viewNotification=[[UIView alloc] initWithFrame:CGRectMake(0, -64, screenSize.width, 64)];
    [viewNotification setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *btnCross=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnCross setFrame:CGRectMake(screenSize.width-45, 17, 30, 30)];
    [btnCross setImage:[UIImage imageNamed:@"cross.png"]  forState:UIControlStateNormal];
    [btnCross addTarget:self action:@selector(removeNotificationView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageViewIcon=[[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 50, 50)];
    [imageViewIcon setImage:[UIImage imageNamed:@"john_smith.png"]];
    [viewNotification addSubview:imageViewIcon];
    
    UILabel *lblName=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageViewIcon.frame)+8, 8, 200, 25)];
    [lblName setText:@"Tom"];
    [lblName setFont:[DingoUISettings boldFontWithSize:15]];
    [viewNotification addSubview:lblName];
    
    UILabel *lblMessageText=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageViewIcon.frame)+8, CGRectGetMaxY(lblName.frame)-5, 200, 25)];
    [lblMessageText setText:@"Last line of conversation goes here"];
    [lblMessageText setFont:[DingoUISettings fontWithSize:13]];
    [viewNotification addSubview:lblMessageText];
    
    
    [viewNotification addSubview:btnCross];
    
    
    
    [self.window.rootViewController.view addSubview:viewNotification];
    
    
    [UIView animateWithDuration:0.6 animations:^{
        [viewNotification setFrame:CGRectMake(0, 0, screenSize.width, 64)];
    }];
    
    
}

-(void)removeNotificationView{
    if (viewNotification) {
        [UIView animateWithDuration:0.6 animations:^{
        [viewNotification setFrame:CGRectMake(0, -64, screenSize.width, 64)];
        } completion:^(BOOL finish){
            if (finish) {
                [viewNotification removeFromSuperview];
            }
        }];

    }
}



#pragma mark CoreLocation methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (!oldLocation || (oldLocation.coordinate.latitude != newLocation.coordinate.latitude && oldLocation.coordinate.longitude != newLocation.coordinate.longitude)) {
        [AppManager sharedManager].currentLocation = newLocation;
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
