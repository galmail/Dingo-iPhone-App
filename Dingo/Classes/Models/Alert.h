//
//  Alert.h
//  Dingo
//
//  Created by Asatur Galstyan on 9/29/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alert : NSManagedObject

@property (nonatomic, retain) NSString * alert_description;
@property (nonatomic, retain) NSString * alert_id;
@property (nonatomic, retain) NSNumber * on;
@property (nonatomic, retain) NSString * event_id;

@end
