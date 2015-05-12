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
#import "EventsViewController.h"
#import "SearchTicketsViewController.h"
#import "MessagesViewController.h"
#import "ListTicketsViewController.h"
#import "ChatViewController.h"
#import "Stripe.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "Mixpanel.h"
#import "AppsFlyerTracker.h"



#import "GAI.h"


@implementation AppDelegate

@synthesize viewNotification;

#pragma mark - app delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [AppsFlyerTracker sharedTracker].appleAppID = @"893538091"; // The Apple app ID. Example 34567899
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"qXbMEujGAHWM74qmW5XfUH";
    [AppsFlyerTracker sharedTracker].currencyCode = @"GBP";
    
    #define MIXPANEL_TOKEN @"e596cf8b99f23cd3aa5bd2f16b898ae6"
    
    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Later, you can get your instance with
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
	
    [mixpanel track:@"Open App"];
    
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
    
    [Fabric with:@[TwitterKit]];
    
    //-- Set Notification
	//keep in mind this would be a "better" (more standard) way to check for api availability
	//if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
	
	DLog(@"userInfo: %@", [AppManager sharedManager].userInfo);
	DLog(@"allow_push_notifications: %i", [[[AppManager sharedManager].userInfo valueForKey:@"allow_push_notifications"] boolValue]);
	
	if (![AppManager sharedManager].userInfo || [[[AppManager sharedManager].userInfo valueForKey:@"allow_push_notifications"] boolValue]) {
		DLog(@"REGISTERING FOR PUSH");
		
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")){
			
			[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
			[[UIApplication sharedApplication] registerForRemoteNotifications];
		}else{
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
		}
	} else DLog(@"NOT REGISTERING FOR PUSH");

    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction :kPaypalProductionID,
                                                           PayPalEnvironmentSandbox : kPaypalSendboxID }];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-54649568-2"];
	
    if ([AppManager sharedManager].token) {
        
        [mixpanel identify: [[AppManager sharedManager].userInfo valueForKey:@"email"] ];
        
        if([[AppManager sharedManager].userInfo valueForKey:@"fb_id"]){
            [mixpanel.people set:@{@"Login": [[AppManager sharedManager].userInfo valueForKey:@"fb_id"], @"first_name": [[AppManager sharedManager].userInfo valueForKey:@"name"], @"$email": [[AppManager sharedManager].userInfo valueForKey:@"email"]}];
        } else {
            [mixpanel.people set:@{@"first_name": [[AppManager sharedManager].userInfo valueForKey:@"name"], @"$email": [[AppManager sharedManager].userInfo valueForKey:@"email"]}];
        }
        
        [mixpanel track:@"Returning User"];
        [mixpanel timeEvent:@"Session Time"];
        
        SlidingViewController *viewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"SlidingViewController"];
        self.window.rootViewController = viewController;
    }
    application.applicationIconBadgeNumber = 0;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[AppManager sharedManager] save];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Session Time"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    application.applicationIconBadgeNumber = 0;
    
    [[Harpy sharedInstance] checkVersionDaily];
	
	//if the user changed push notification settings and is on the settings screen this will update it ;)
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteNotificationsChanged" object:nil];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[AppManager sharedManager] save];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Session Time"];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}


#pragma mark - notifications

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
	DLog(@"notificationSettings: %@", notificationSettings);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	DLog();
	
	//should we set this to yes ? the app automatically tried to register for push and if it gets here, push is on...
	[[AppManager sharedManager].userInfo setValue:@YES forKey:@"allow_push_notifications"];
	
	// Show the device token obtained from apple to the log
	NSString *newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	[AppManager sharedManager].deviceToken = newToken;
	
	DLog(@"deviceToken - %@",newToken);
	DLog(@"NSSTRING_HAS_DATA - %i", NSSTRING_HAS_DATA([AppManager sharedManager].userInfo[@"email"]));
	DLog(@"[[NSUserDefaults standardUserDefaults] objectForKey:@\"users_email\"] - %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"users_email"]);
	
	
	if (NSSTRING_HAS_DATA([AppManager sharedManager].userInfo[@"email"]) || [[NSUserDefaults standardUserDefaults] objectForKey:@"users_email"]) {
		
		DLog(@">>>>PASSED CHECK (if (NSSTRING_HAS_DATA([AppManager sharedManager].userInf...)");
		
		if ([[AppManager sharedManager].deviceToken length]) {
			DLog(@">>>>PASSED CHECK (if ([[AppManager sharedManager].deviceToken length])");
			
			NSDictionary *params = @{ @"uid":[AppManager sharedManager].deviceToken.length > 0 ? [AppManager sharedManager].deviceToken : @"",
									  @"brand":@"Apple",
									  @"model": [[UIDevice currentDevice] platformString],
									  @"os":[[UIDevice currentDevice] systemVersion],
									  @"app_version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
									  @"location" : [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude ]
									  };
			
			DLog(@"params: %@", params);
			[WebServiceManager registerDevice:params completion:^(id response, NSError *error) {
				DLog(@"AD registerDevice response - %@", response);
				DLog(@"AD registerDevice error - %@", error);
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteNotificationsChanged" object:error];
			}];
		} else DLog(@">>>>DID NOT PASS CHECK (if ([[AppManager sharedManager].deviceToken length])");
	} else DLog(@">>>>DID NOT PASS CHECK (if (NSSTRING_HAS_DATA([AppManager sharedManager].userInf...)");
	
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
	DLog(@"error: %@", error.localizedDescription);
	
	//should we set this to no ?
	//[[AppManager sharedManager].userInfo setValue:@NO forKey:@"allow_push_notifications"];
	
	// we post a notification to disable settings switch ;)
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteNotificationsChanged" object:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
	DLog(@"userInfo: %@ ", userInfo);
	
	// if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
	//[self showNotiFicationView:userInfo];
	//    }else{
	//            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Dingo" message:@"You received a new message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	//            [alertView show];
	//    }
	//
	
	if ( application.applicationState == UIApplicationStateActive ) {
		
		if ([self.window.rootViewController isKindOfClass:[SlidingViewController class]]){
			SlidingViewController *vc = (SlidingViewController *)self.window.rootViewController;
			
			DingoNavigationController *nc = (DingoNavigationController *)vc.topViewController;
			
			HomeTabBarController *tabBarConroller = (HomeTabBarController *)nc.topViewController;
			[[DataManager shared] fetchMessagesWithCompletion:^(BOOL finished) {
				if ([tabBarConroller isKindOfClass:[EventsViewController class]]|| [tabBarConroller isKindOfClass:[ListTicketsViewController class]] || [tabBarConroller isKindOfClass:[MessagesViewController class]] || [tabBarConroller isKindOfClass:[SearchTicketsViewController class]] || [tabBarConroller isKindOfClass:[HomeTabBarController class]])
					[tabBarConroller updateMessageCount];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"messageReceived" object:nil];
				
				
			}];
            //this sets the variable sender to the sender ID
            NSArray *arrayApsMessages=[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] componentsSeparatedByString:@":"];
            NSString *sender = ([arrayApsMessages count]>0?[arrayApsMessages objectAtIndex:0]:@"Dingo");
            
            //check if on chat with the message sender
            if ([tabBarConroller isKindOfClass:[ChatViewController class]] && [sender isEqualToString:lastChatUser]){
                DLog();
                
            } else {
                [self showNotiFicationView:userInfo];
            }
		}
  
	}
	
}

#pragma mark - custom methods

//sugestion: create a NotificationView class and remove most of the code from app delegate

-(void)showNotiFicationView:(NSDictionary *)payLoad {
	DLog();
    viewNotification=[[UIView alloc] initWithFrame:CGRectMake(0,-64, screenSize.width, 64)];
    [viewNotification setBackgroundColor:[UIColor colorWithRed:48.f/255.0f green:73.0f/255.0f blue:80.0f/255.0f alpha:1.0f]];
	
    UIButton *btnCross=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnCross setFrame:CGRectMake(screenSize.width-45, 15, 40, 40)];
    [btnCross setImage:[UIImage imageNamed:@"cross.png"]  forState:UIControlStateNormal];
    [btnCross addTarget:self action:@selector(removeNotificationView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageViewIcon=[[UIImageView alloc] initWithFrame:CGRectMake(10, 9.5, 45, 45)];
    [imageViewIcon setImage:[UIImage imageNamed:@"placeholder_avatar2.jpg"]];
    [viewNotification addSubview:imageViewIcon];
    [imageViewIcon.layer setCornerRadius:22.5];
    [imageViewIcon.layer setMasksToBounds:YES];
    
     NSArray *arrayApsMessages=[[[payLoad objectForKey:@"aps"] objectForKey:@"alert"] componentsSeparatedByString:@":"];
    
    UILabel *lblName=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageViewIcon.frame)+8, 8, 200, 25)];
    [lblName setText:([arrayApsMessages count]>0?[arrayApsMessages objectAtIndex:0]:@"Dingo")];
    [lblName setTextColor:[UIColor whiteColor]];
    [lblName setFont:[DingoUISettings boldFontWithSize:15]];
    [viewNotification addSubview:lblName];
    
    UILabel *lblMessageText=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageViewIcon.frame)+8, CGRectGetMaxY(lblName.frame)-5, 200, 25)];
    [lblMessageText setText:([arrayApsMessages count]>1?[arrayApsMessages objectAtIndex:1]:@" ")];
    [lblMessageText setFont:[DingoUISettings fontWithSize:13]];
    [lblMessageText setTextColor:[UIColor whiteColor]];
    [viewNotification addSubview:lblMessageText];
    
    
    [viewNotification addSubview:btnCross];
    
    
    
    //[self.window.rootViewController.view addSubview:viewNotification];
    [[[UIApplication sharedApplication] keyWindow] addSubview:viewNotification];
    
    [UIView animateWithDuration:0.2 animations:^{
        [viewNotification setFrame:CGRectMake(0, 0, screenSize.width, 64)];
        [self performSelector:@selector(removeNotificationView) withObject:nil afterDelay:1.5];
    }];
    
    
}

-(void)removeNotificationView{
    if (viewNotification) {
        [UIView animateWithDuration:0.2 animations:^{
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
