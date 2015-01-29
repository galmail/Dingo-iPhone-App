//
//  Event.h
//  Dingo
//
//  Created by Asatur Galstyan on 7/23/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * event_desc;
@property (nonatomic, retain) NSString * event_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) NSString * thumbUrl;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSNumber * fromPrice;
@property (nonatomic, retain) NSNumber * test;
@property (nonatomic, retain) NSNumber * tickets;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * primary_ticket_seller_url;

@end
