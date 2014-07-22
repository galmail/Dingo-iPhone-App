//
//  EventCategory.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/21/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EventCategory : NSManagedObject

@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) NSString * thumbUrl;

@end
