//
//  Alert.h
//  Dingo
//
//  Created by Tigran Aslanyan on 22.08.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alert : NSManagedObject

@property (nonatomic, retain) NSString * alert_description;
@property (nonatomic, retain) NSString * alert_id;

@end
