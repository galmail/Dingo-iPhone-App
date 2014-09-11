//
//  Message.h
//  Dingo
//
//  Created by Tigran Aslanyan on 08.09.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSString * message_id;
@property (nonatomic, retain) NSString * receiver_id;
@property (nonatomic, retain) NSString * sender_id;
@property (nonatomic, retain) NSData * sender_avatar;
@property (nonatomic, retain) NSString * sender_name;
@property (nonatomic, retain) NSString * sender_avatar_url;

@end
