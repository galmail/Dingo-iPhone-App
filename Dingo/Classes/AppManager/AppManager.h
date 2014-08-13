//
//  AppManager.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/16/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface AppManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) NSMutableDictionary *draftTicket;

+(AppManager *)sharedManager;

- (BOOL)justInstalled;

- (void)save;
- (void)saveContext;

+ (void)showAlert:(NSString*)message;

@end
