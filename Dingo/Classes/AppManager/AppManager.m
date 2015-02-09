//
//  AppManager.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/16/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "AppManager.h"

//global ivar to make sure we only see one alert
UIAlertView *appManagerAlert = nil;

@implementation AppManager

+ (AppManager*)sharedManager {
    
    static AppManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AppManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.token = [defaults valueForKey:@"token"];
    self.userInfo = [[defaults valueForKey:@"userInfo"] mutableCopy];
}

- (BOOL)justInstalled {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:@"justInstalled"]) {
        return [[defaults valueForKey:@"justInstalled"] boolValue];
    } else {
        [defaults setBool:NO forKey:@"justInstalled"];
        return YES;
    }
    
    return NO;
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:self.token forKey:@"token"];
    [defaults setValue:self.userInfo forKey:@"userInfo"];
    
    [defaults synchronize];
    
    [self saveContext];
}

- (void)saveContext
{
    if (![NSThread isMainThread]) {
        NSLog(@"main thread %d", [NSThread isMainThread]);
    }
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Dingo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Dingo.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to MFthe application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark ---

+ (void)showAlert:(NSString*)message {
	//don't repeat alerts with same message
	if (![appManagerAlert.message isEqualToString:message]) {
		appManagerAlert = [[UIAlertView alloc] initWithTitle:@"Dingo" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		appManagerAlert.delegate = self;
		[appManagerAlert show];
	}
}

#pragma mark - alert delegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DLog();
	appManagerAlert = nil;
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
+ (void)alertViewCancel:(UIAlertView *)alertView {
	DLog();
	appManagerAlert = nil;
}

@end
