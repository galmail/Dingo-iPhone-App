//
//  Ticket.h
//  Dingo
//
//  Created by Asatur Galstyan on 8/31/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Ticket : NSManagedObject

@property (nonatomic, retain) NSString * delivery_options;
@property (nonatomic, retain) NSString * event_id;
@property (nonatomic, retain) NSNumber * face_value_per_ticket;
@property (nonatomic, retain) NSNumber * number_of_tickets;
@property (nonatomic, retain) NSNumber * number_of_tickets_sold;
@property (nonatomic, retain) NSString * payment_options;
@property (nonatomic, retain) NSData * photo1;
@property (nonatomic, retain) NSData * photo2;
@property (nonatomic, retain) NSData * photo3;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * seat_type;
@property (nonatomic, retain) NSString * ticket_desc;
@property (nonatomic, retain) NSString * ticket_id;
@property (nonatomic, retain) NSString * ticket_type;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * user_email;
@property (nonatomic, retain) NSData * user_photo;
@property (nonatomic, retain) NSNumber * offers_count;
@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSNumber * available;

@end
