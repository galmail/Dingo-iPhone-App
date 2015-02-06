//
//  DataManager.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DataManager.h"

#import "DingoUtilites.h"
#import "WebServiceManager.h"
#import "AppManager.h"
#import "CommonDocUnAuth.h"


typedef void (^GroupsDelegate)(id eventDescription, NSUInteger groupIndex);


@implementation DataManager

#pragma makr - Initialization

+ (DataManager *)shared {
    static DataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

#pragma mark - Events Requests

- (NSArray *)allEventsOfSelectedLocation {
    
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(tickets != %d && (city == %@))",0,[[NSUserDefaults standardUserDefaults] objectForKey:@"city"]]];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    return events;
}

- (NSArray *)allEvents {
    
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    //[request setPredicate:[NSPredicate predicateWithFormat:@"(tickets != %d)",0]];
    request.predicate = [NSPredicate predicateWithFormat:@"for_sale == 1"];

    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    return events;
}

-(NSArray *)allEventsWithAndWithoutTickets{
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    //[request setPredicate:[NSPredicate predicateWithFormat:@"(tickets != %d)",0]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    return events;
}

- (NSArray *)featuredEvents {
    
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    request.predicate = [NSPredicate predicateWithFormat:@"featured == 1"];
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    return events;
}

- (void)allEventsWithCompletion:( void (^) (BOOL finished))handler {
    //NSLog(@"userInfo=%@",[AppManager sharedManager].userInfo);
    NSDictionary* params = @{@"city":[AppManager sharedManager].userInfo[@"city"],@"any":@"true"};
   
    if ([AppManager sharedManager].currentLocation != nil) {
        params = @{@"location": [NSString stringWithFormat:@"%f,%f", [AppManager sharedManager].currentLocation.coordinate.latitude, [AppManager sharedManager].currentLocation.coordinate.longitude], @"city":[AppManager sharedManager].userInfo[@"city"] };
    }

	[WebServiceManager events:params completion:^(id response, NSError *error) {
		//DLog(@"DM events: %@", response);
        if (response[@"events"]) {
            NSArray *events = response[@"events"];
            
            // remove deleted events from local database
            NSArray *eventIDs = [events valueForKey:@"id"];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
            request.predicate = [NSPredicate predicateWithFormat:@"NOT (event_id IN %@)", eventIDs];
            
            NSArray *eventsToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
            if (eventsToRemove.count) {
                for (Event *toRemove in eventsToRemove) {
                    [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
                }
            }
            
            for (NSDictionary *event in events) {
                [self addOrUpdateEvent:event];
            }
            
            [[AppManager sharedManager] saveContext];
        }
        handler(YES);
        
    }];
}

- (void)addOrUpdateEvent:(NSDictionary *)info {

    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSString *eventID = info[@"id"];
    NSString *name = info[@"name"];
    NSString *thumbUrl = info[@"thumb"];
	NSString *primary_ticket_seller_url = info[@"primary_ticket_seller_url"];
    NSString *categoryID = info[@"category_id"];
    NSString *description = info[@"description"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    request.predicate = [NSPredicate predicateWithFormat:@"event_id == %@", eventID];
    
    NSError *error = nil;
    Event *event = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    if (events.count > 0) {
        event = events[0];
    } else {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
        event.event_id = eventID;
    }
    
    event.name = name;
    event.event_desc = description;
    event.category_id = categoryID;
    event.thumbUrl = thumbUrl;
	event.primary_ticket_seller_url = primary_ticket_seller_url;
    event.featured = [NSNumber numberWithInt:[info[@"featured"] intValue]];
    event.for_sale = [NSNumber numberWithInt:[info[@"for_sale"] intValue]];
    event.fromPrice = [NSNumber numberWithFloat:[info[@"min_price"] floatValue]];
    event.tickets = [NSNumber numberWithInt:[info[@"available_tickets"] intValue]];
    event.test = [NSNumber numberWithBool:[info[@"test"] boolValue]];
    event.address = info[@"address"];
    event.city = info[@"city"];
    event.postalCode = info[@"postcode"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ";
    
    NSDate *date = [formatter dateFromString:info[@"date"]];
    event.date = date;
    event.endDate = [formatter dateFromString:info[@"end_date"]];
    
}

- (NSUInteger)eventsDateRange {
    NSArray *events = [self allEvents];
    BOOL before = NO;
    BOOL after = NO;
    
    for (Event *dict in events) {

        NSDate *date = dict.date;
        if ([DingoUtilites daysBetween:date and:[NSDate date]] > 0) {
            before = YES;
            continue;
        }
        
        if ([DingoUtilites daysBetween:[NSDate date] and:date] > 0) {
            after = YES;
            continue;
        }
    }
    
    return before + after;
}

- (NSArray *)eventsBeforeDate:(NSDate *)date {
    NSArray *events = [self allEvents];
    NSMutableArray *result = [NSMutableArray array];
    
    for (Event *dict in events) {
        NSDate *curDate = dict.date;
        if ([DingoUtilites daysBetween:curDate and:date] > 0) {
            [result addObject:dict];
        }
    }
    
    return [result copy];
}

- (NSArray *)eventsAfterDate:(NSDate *)date {
    NSArray *events = [self allEvents];
    NSMutableArray *result = [NSMutableArray array];
    
    for (Event *dict in events) {
        NSDate *curDate = dict.date;
        if ([DingoUtilites daysBetween:date and:curDate] >= 0) {
            [result addObject:dict];
        }
    }
    
    return [result copy];
}

- (NSArray *)ticketsBeforeDate:(NSDate *)date {
    NSArray *tickets = [self userTickets];
    NSMutableArray *result = [NSMutableArray array];
    
    for (Ticket *ticket in tickets) {
        Event *event = [self eventByID:ticket.event_id];
        NSDate *curDate = event.date;
        if ([DingoUtilites daysBetween:curDate and:date] > 0) {
            [result addObject:ticket];
        }
    }
    
    return [result copy];
}


//this sorted events strictly even they have same date
- (NSArray *)tickets_BeforeDate:(NSDate *)date {
    NSArray *tickets = [self userTickets];
    NSMutableArray *result = [NSMutableArray array];
    
    for (Ticket *ticket in tickets) {
        Event *event = [self eventByID:ticket.event_id];
       // NSDate *curDate = event.date;
        if ([event.date compare:date]==NSOrderedAscending) {
            [result addObject:ticket];
        }
    }
    
    return [result copy];
}


- (NSArray *)ticketsAfterDate:(NSDate *)date {
    NSArray *tickets = [self userTickets];
    NSMutableArray *result = [NSMutableArray array];
    
    for (Ticket *ticket in tickets) {
        Event *event = [self eventByID:ticket.event_id];
        NSDate *curDate = event.date;
        if ([DingoUtilites daysBetween:date and:curDate] >= 0) {
            [result addObject:ticket];
        }
    }
    
    return [result copy];
}


//this sorted events strictly even they have same date
- (NSArray *)tickets_AfterDate:(NSDate *)date {
    NSArray *tickets = [self userTickets];
    NSMutableArray *result = [NSMutableArray array];
    
    for (Ticket *ticket in tickets) {
        Event *event = [self eventByID:ticket.event_id];
       // NSDate *curDate = event.date;
        if ([event.date compare:date]==NSOrderedDescending || [event.date compare:date]==NSOrderedSame) {
            [result addObject:ticket];
        }
    }
    
    return [result copy];
}



//1) Selling - all tickets obtained in "Get My Tickets" API were available = TRUE.
- (NSArray *)ticketsSelling {
	NSArray *tickets = [self userTickets];
	NSMutableArray *result = [NSMutableArray array];
	
	for (Ticket *ticket in tickets) {
		if (ticket.available.boolValue &&
			ticket.user_id.intValue == [[AppManager sharedManager].userInfo[@"id"] intValue]) {
			
			[result addObject:ticket];
		}
	}
	
	return [result copy];
}

//2) Sold - all tickets obtained in "Get My Tickets" API were available = FALSE && number of tickets = 0.
- (NSArray *)ticketsSold {
	NSArray *tickets = [self userTickets];
	NSMutableArray *result = [NSMutableArray array];
	
	for (Ticket *ticket in tickets) {
		if (!ticket.available.boolValue &&
			ticket.number_of_tickets.intValue == 0 &&
			ticket.user_id.intValue == [[AppManager sharedManager].userInfo[@"id"] intValue]) {
			
			[result addObject:ticket];
		}
	}
	
	return [result copy];
}

//2) Purchased - The logic for purchased tickets is: user_id<>current_user
- (NSArray *)ticketsPurchased {
	NSArray *tickets = [self userTickets];
	NSMutableArray *result = [NSMutableArray array];
	
	for (Ticket *ticket in tickets) {
		if (ticket.user_id.intValue != [[AppManager sharedManager].userInfo[@"id"] intValue]) {
			[result addObject:ticket];
		}
	}
	
	return [result copy];
}



//T.A. from search result
- (NSUInteger)eventsFromSearchGroupsCount:(NSArray*)searchedEvents {
    __block NSUInteger groupsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex > groupsCount) {
            groupsCount = groupIndex;
        }
    };
    
    [self enumerateEventFromSearchGroups:&delegate Events:searchedEvents];
    return groupsCount + 1;
}

- (NSUInteger)eventsGroupsCount {
    __block NSUInteger groupsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex > groupsCount) {
            groupsCount = groupIndex;
        }
    };
    
    [self enumerateEventGroups:&delegate];
    return groupsCount + 1;
}

- (NSUInteger)featuredEventsGroupsCount {
    __block NSUInteger groupsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex > groupsCount) {
            groupsCount = groupIndex;
        }
    };
    
    [self enumerateFeaturedEventGroups:&delegate];
    return groupsCount + 1 ;
}

- (NSUInteger)eventsGroupsCountForCategories:(NSArray*)categories {
    
    __block NSUInteger groupsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex > groupsCount) {
            groupsCount = groupIndex;
        }
    };
    
    [self enumerateEventGroups:&delegate categories:categories];
    return groupsCount+1;
    
}

//T.A. from search result
- (NSUInteger)eventsFromSearchCountWithGroupIndex:(NSUInteger)group Events:(NSArray*)searchedEvents{
    __block NSUInteger eventsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex == group) {
            eventsCount++;
        }
    };
    
    [self enumerateEventFromSearchGroups:&delegate Events:searchedEvents];
    return eventsCount;
}

- (NSUInteger)eventsCountWithGroupIndex:(NSUInteger)group {
    __block NSUInteger eventsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex == group) {
            eventsCount++;
        }
    };
    
    [self enumerateEventGroups:&delegate];
    return eventsCount;
}

- (NSUInteger)featuredEventsCountWithGroupIndex:(NSUInteger)group {
    __block NSUInteger eventsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex == group) {
            eventsCount++;
        }
    };
    
    [self enumerateFeaturedEventGroups:&delegate];
    return eventsCount;
}


- (NSUInteger)eventsCountWithGroupIndex:(NSUInteger)group categories:(NSArray*)categories {
    __block NSUInteger eventsCount = 0;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex == group) {
            eventsCount++;
        }
    };
    
    [self enumerateEventGroups:&delegate categories:categories];
    return eventsCount;
}


- (Event *)eventFromSearchDescriptionByIndexPath:(NSIndexPath *)path Events:(NSArray*)searchedEvents{
    __block uint eventsIndex = 0;
    __block Event *event = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex != path.section) {
            return;
        }
        
        if (eventsIndex++ != path.row) {
            return;
        }
        
        event = eventDescription;
    };
    
    [self enumerateEventFromSearchGroups:&delegate Events:searchedEvents];
    return event;
}

- (Event *)eventDescriptionByIndexPath:(NSIndexPath *)path {
    __block uint eventsIndex = 0;
    __block Event *event = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex != path.section) {
            return;
        }
        
        if (eventsIndex++ != path.row) {
            return;
        }
        
        event = eventDescription;
    };
    
    [self enumerateEventGroups:&delegate];
    return event;
}

- (Event *)featuredEventDescriptionByIndexPath:(NSIndexPath *)path {
    __block uint eventsIndex = 0;
    __block Event *event = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex != path.section) {
            return;
        }
        
        if (eventsIndex++ != path.row) {
            return;
        }
        
        event = eventDescription;
    };
    
    [self enumerateFeaturedEventGroups:&delegate];
    return event;
}

- (Event *)eventDescriptionByIndexPath:(NSIndexPath *)path categories:categories {
    __block uint eventsIndex = 0;
    __block Event *event = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger groupIndex) {
        if (groupIndex != path.section) {
            return;
        }
        
        if (eventsIndex++ != path.row) {
            return;
        }
        
        event = eventDescription;
    };
    
    [self enumerateEventGroups:&delegate categories:categories];
    return event;
}


- (NSDate *)eventFromSearchGroupDateByIndex:(NSUInteger)groupIndex Events:(NSArray*)searchedEvents{
    __block NSDate *date = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger grIndx) {
        if (groupIndex != grIndx) {
            return;
        }
        
        date = eventDescription.date;
    };
    
    [self enumerateEventFromSearchGroups:&delegate Events:searchedEvents];
    return date;
}


- (NSDate *)eventGroupDateByIndex:(NSUInteger)groupIndex {
    __block NSDate *date = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger grIndx) {
        if (groupIndex != grIndx) {
            return;
        }
        
        date = eventDescription.date;
    };
    
    [self enumerateEventGroups:&delegate];
    return date;
}

- (NSDate *)featuredEventGroupDateByIndex:(NSUInteger)groupIndex {
    __block NSDate *date = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger grIndx) {
        if (groupIndex != grIndx) {
            return;
        }
        
        date = eventDescription.date;
    };
    
    [self enumerateFeaturedEventGroups:&delegate];
    return date;
}

- (NSDate *)eventGroupDateByIndex:(NSUInteger)groupIndex categories:categories{
    __block NSDate *date = nil;
    GroupsDelegate delegate = ^(Event *eventDescription, NSUInteger grIndx) {
        if (groupIndex != grIndx) {
            return;
        }
        
        date = eventDescription.date;
    };
    
    [self enumerateEventGroups:&delegate categories:categories];
    return date;
}

- (Event*)eventByID:(NSString*)eventID {
	
	//NSArray *events = [self allEvents];
    NSArray *events = [self allEventsWithAndWithoutTickets];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_id == %@", eventID];
    
    NSArray *filteredEvents = [events filteredArrayUsingPredicate:predicate];
    if (filteredEvents.count) {
        return filteredEvents[0];
    }
    
    return nil;
}

+ (NSString *)eventLocation:(Event *)data {
    
    NSString *location = @"";
    if (data.address.length > 0) {
        location = data.address;
    }
    
    if (data.city.length > 0) {
        
        if (location.length > 0) {
            location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", data.city]];
        } else {
            location = data.city;
        }
    }
    
    if (data.postalCode.length > 0) {
        if (location.length > 0) {
            location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", data.postalCode]];
        } else {
            location = data.postalCode;
        }
    }
    
    return location;
}


#pragma mark - Other Requests

- (Ticket *)ticketByID:(NSString *)ticketID {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
    request.predicate = [NSPredicate predicateWithFormat:@"ticket_id == %@", ticketID];
    NSArray *tickets = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    if (tickets.count) {
        return tickets[0];
    }
    
    return nil;
}

- (void)allTiketsForEvents:(NSMutableArray *)events withCompletion:( void (^) (BOOL finished))handler {
    
    if (events.count > 0) {
        [self allTicketsByEventID:events[0] completion:^(BOOL finished) {
            [events removeObjectAtIndex:0];
           
            [self allTiketsForEvents:events withCompletion:handler];
        }];
    } else {
        handler (YES);
    }
    
}

- (NSArray *)allTicketsByEventID:(NSString *)eventID {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
    request.predicate = [NSPredicate predicateWithFormat:@"event_id == %@", eventID];
    request.sortDescriptors=[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES], nil];
    NSArray *tickets = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    if (tickets.count) {
        return tickets;
    }
    
    return nil;
}

- (void)allTicketsByEventID:(NSString *)eventID completion:( void (^) (BOOL finished))handler {
//    
//    NSDictionary *params = @{@"event_id":eventID};
//    [WebServiceManager tickets:params completion:^(id response, NSError *error) {
//        if (response[@"tickets"]) {
//            NSArray *tickets = response[@"tickets"];
//            
//            // remove deleted tickets from local database
//            NSArray *ticketIDs = [tickets valueForKey:@"id"];
//            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
//            request.predicate = [NSPredicate predicateWithFormat:@"NOT(ticket_id IN %@) && event_id == %@", ticketIDs, eventID];
//            
//            NSArray *ticketsToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
//            if (ticketsToRemove.count) {
//                for (Ticket *toRemove in ticketsToRemove) {
//                    [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
//                }
//            }
//            
//            for (NSDictionary *ticket in tickets) {
//                [self addOrUpdateTicket:ticket];
//            }
//            
//            [[AppManager sharedManager] saveContext];
//        }
//        handler(YES);
//    }];
	
	NSLog(@"eventID: %@", eventID);
	
    NSDictionary *params = @{@"event_id":eventID};
    [[CommonDocUnAuth sharedDocument] getPath:@"tickets" parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
                if (response[@"tickets"]) {

                    
                    dispatch_queue_t main_queue = dispatch_get_main_queue();
                    dispatch_queue_t request_queue = dispatch_queue_create("com.app.request", NULL);
                    
                  
                    dispatch_async(request_queue, ^{
                                            NSArray *tickets = response[@"tickets"];
                        
                                            // remove deleted tickets from local database
                                            NSArray *ticketIDs = [tickets valueForKey:@"id"];
                                            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
                                            request.predicate = [NSPredicate predicateWithFormat:@"NOT(ticket_id IN %@) && event_id == %@", ticketIDs, eventID];
                        
                                            NSArray *ticketsToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
                                            if (ticketsToRemove.count) {
                                                for (Ticket *toRemove in ticketsToRemove) {
                                                    [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
                                                }
                                            }
                                
                                            for (NSDictionary *ticket in tickets) {
                                                [self addOrUpdateTicket:ticket];
                                            }
                                            
                        dispatch_sync(main_queue, ^{
                            [[AppManager sharedManager] saveContext];
                            handler(YES);
                        });
                    });

                }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         handler(YES);
    }];
    
}


- (void)addOrUpdateTicket:(NSDictionary *)info {
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    
    NSString *ticketID = info[@"id"];
    NSString *eventID = info[@"event_id"];
    NSString *description = ![info[@"description"] isKindOfClass:[NSNull class]] ? info[@"description"] : @"";
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
    request.predicate = [NSPredicate predicateWithFormat:@"ticket_id == %@", ticketID];
    
    NSError *error = nil;
    Ticket *ticket = nil;
    NSArray *tickets = [context executeFetchRequest:request error:&error];
    if (tickets.count > 0) {
        ticket = tickets[0];
    } else {
        ticket = [NSEntityDescription insertNewObjectForEntityForName:@"Ticket" inManagedObjectContext:context];
        ticket.ticket_id = ticketID;
    }
	
	ticket.available = @([info[@"available"] boolValue]);
    ticket.facebook_id = info[@"user_facebook_id"];
    ticket.ticket_desc = description;
    ticket.event_id = eventID;
    ticket.delivery_options = info[@"delivery_options"];
    ticket.number_of_tickets = @([info[@"number_of_tickets"] intValue]);
    ticket.payment_options = ![info[@"payment_options"] isKindOfClass:[NSNull class]] ? info[@"payment_options"] : @"";
    ticket.ticket_type = info[@"ticket_type"];
    ticket.face_value_per_ticket =  @([info[@"face_value_per_ticket"] floatValue]);
    ticket.price = @([info[@"price"] floatValue]);
    ticket.seat_type = ![info[@"seat_type"] isKindOfClass:[NSNull class]] ? info[@"seat_type"] : @"";
    if (info[@"photo1_thumb"]) {
        ticket.photo1 = [NSData dataWithContentsOfURL:[NSURL URLWithString:info[@"photo1_thumb"]]];
    }
    if (info[@"photo2_thumb"]) {
        ticket.photo2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:info[@"photo2_thumb"]]];
    }
    if (info[@"photo3_thumb"]) {
        ticket.photo1 = [NSData dataWithContentsOfURL:[NSURL URLWithString:info[@"photo3_thumb"]]];
    }
    ticket.user_id = @([info[@"user_id"] intValue]);
    if (info[@"user_name"]) {
        ticket.user_name = info[@"user_name"];
    }
    if (info[@"user_email"]) {
        ticket.user_email = info[@"user_email"];
    }
    
    if (info[@"user_photo"]) {
        NSString *user_photo_url = info[@"user_photo"];
        user_photo_url = [user_photo_url stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
        NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_photo_url]];
        ticket.user_photo = data;
    }
    
    ticket.offers_count =@([info[@"number_of_offers"] intValue]);
}

- (NSArray *)userTickets {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
	//why is this here???? userTicketsWithCompletion has paramter mine = true already
    //request.predicate = [NSPredicate predicateWithFormat:@"user_id == %@", [AppManager sharedManager].userInfo[@"id"]];
    NSArray *tickets = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    if (tickets.count) {
        return tickets;
    }
    
    return nil;
}

- (void)userTicketsWithCompletion:( void (^) (BOOL finished))handler {
	
	//this api call did not use to have the mine = true parameter, howeber mytickets api assumes this
    NSDictionary *params = @{@"auth_token":[AppManager sharedManager].token, @"mine":@(YES)};
    [WebServiceManager tickets:params completion:^(id response, NSError *error) {
        if (response[@"tickets"]) {
            NSArray *tickets = response[@"tickets"];
            
            // remove deleted tickets from local database
            NSArray *ticketIDs = [tickets valueForKey:@"id"];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
            request.predicate = [NSPredicate predicateWithFormat:@"NOT (ticket_id IN %@)", ticketIDs];
            
            NSArray *ticketsToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
            if (ticketsToRemove.count) {
                for (Ticket *toRemove in ticketsToRemove) {
                    [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
                }
            }
            
            for (NSDictionary *ticket in tickets) {
                [self addOrUpdateTicket:ticket];
            }
            
            [[AppManager sharedManager] saveContext];
        }
        handler(YES);
    }];
}


- (NSArray *)allFriends {
    static NSArray *friends = nil;
    if (friends) {
        return friends;
    }
    
    friends = [self loadRecordsFromPlist:@"messages"];
    return friends;
}

- (NSArray *)allCities {
    static NSArray *cities = nil;
    if (cities) {
        return cities;
    }
    
    cities = [self loadRecordsFromPlist:@"cities"];
    return cities;
}

#pragma mark - Offers Requests

- (NSArray *)allOffers {
    static NSArray *offers = nil;
    if (offers) {
        return offers;
    }
    
    offers = [self loadRecordsFromPlist:@"offers"];
    return offers;
}

- (NSUInteger)offersGroupsCount {
    __block NSUInteger groupsCount = 0;
    GroupsDelegate delegate = ^(NSDictionary *eventDescription, NSUInteger groupIndex) {
        if (groupIndex > groupsCount) {
            groupsCount = groupIndex;
        }
    };
    
    [self enumerateOffersGroups:&delegate];
    return groupsCount + 1;
}

- (NSUInteger)offersCountWithGroupIndex:(NSUInteger)group {
    __block NSUInteger offersCount = 0;
    GroupsDelegate delegate = ^(NSDictionary *offerDescription, NSUInteger groupIndex) {
        if (groupIndex == group) {
            offersCount++;
        }
    };
    
    [self enumerateOffersGroups:&delegate];
    return offersCount;
}

- (NSDictionary *)offerDescriptionByIndexPath:(NSIndexPath *)path {
    __block uint offerIndex = 0;
    __block NSDictionary *dict = nil;
    GroupsDelegate delegate = ^(NSDictionary *offerDescription, NSUInteger groupIndex) {
        if (groupIndex != path.section) {
            return;
        }
        
        if (offerIndex++ != path.row) {
            return;
        }
        
        dict = offerDescription;
    };
    
    [self enumerateOffersGroups:&delegate];
    return dict;
}
- (NSString *)offersGroupTitleByIndex:(NSUInteger)groupIndex {
    __block NSString *title = nil;
    GroupsDelegate delegate = ^(NSDictionary *offerDescription, NSUInteger grIndx) {
        if (groupIndex != grIndx) {
            return;
        }
        
        title = offerDescription[@"event"];
    };
    
    [self enumerateOffersGroups:&delegate];
    return title;
}

#pragma mark - Categories Requests

- (NSArray *)allCategories {
    
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"EventCategory"];
    NSError *error = nil;
    NSArray *categories = [context executeFetchRequest:request error:&error];
    
    return categories;
}

- (void)allCategoriesWithCompletion:( void (^) (BOOL finished))handler {
    
    [WebServiceManager categories:nil completion:^(id response, NSError *error) {
        
        if (response[@"categories"]) {
            NSArray *categories = response[@"categories"];
            
            
            // remove deleted categories from local database
            NSArray *categoryIDs = [categories valueForKey:@"id"];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"EventCategory"];
            request.predicate = [NSPredicate predicateWithFormat:@"NOT (category_id IN %@)", categoryIDs];
            
            NSArray *categoriesToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
            if (categoriesToRemove.count) {
                for (EventCategory *toRemove in categoriesToRemove) {
                    [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
                }
            }
            
            for (NSDictionary *category in categories) {
                [self addOrUpdateCategory:category];
            }
            
            [[AppManager sharedManager] saveContext];
        }
        handler(YES);
        
    }];
}

- (void)addOrUpdateCategory:(NSDictionary*)info {
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    
    NSString *categoryID = info[@"id"];
    NSString *name = info[@"name"];
    NSString *thumbUrl = info[@"thumb"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"EventCategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"category_id == %@", categoryID];
    
    NSError *error = nil;
    EventCategory *category = nil;
    NSArray *categories = [context executeFetchRequest:request error:&error];
    if (categories.count > 0) {
        category = categories[0];
    } else {
        category = [NSEntityDescription insertNewObjectForEntityForName:@"EventCategory" inManagedObjectContext:context];
        category.category_id = categoryID;
    }
    
    category.name = name;
    category.thumbUrl = thumbUrl;
    
}

- (EventCategory *)dataByCategoryName:(NSString *)name {
    NSArray *cats = [self allCategories];
    for (EventCategory *cat in cats) {
        if ([name isEqualToString:cat.name]) {
            return cat;
        }
    }
    
    return nil;
}

- (EventCategory *)dataByCategoryID:(NSString *)categoryID {
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"EventCategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"category_id == %@", categoryID];
    
    NSError *error = nil;
    NSArray *categories = [context executeFetchRequest:request error:&error];
    if (categories.count > 0) {
        return categories[0];
    }
    
    return nil;
}

- (NSUInteger)categoryIndexByName:(NSString *)name {
    NSArray *cats = [self allCategories];
    NSUInteger index = 0;
    for (EventCategory *cat in cats) {
        if ([name isEqualToString:cat.name]) {
            return index;
        }
        index++;
    }
    return index;
}

#pragma mark - Private

- (NSArray *)loadRecordsFromPlist:(NSString *)plistName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:filePath];
}


//T.A. from search result
- (void)enumerateEventFromSearchGroups:(GroupsDelegate *)delegate Events:(NSArray*)searchedEvents {
    if (!delegate) {
        return;
    }
    
    NSArray *events = searchedEvents;
    NSDate *curDate = nil;
    uint groupIndex = 0;
    
    for (Event *event in events) {
        NSDate *date = event.date;
        
        if (curDate && [DingoUtilites daysBetween:curDate and:date]) {
            groupIndex++;
        }
        
        curDate = date;
        (*delegate)(event, groupIndex);
    }
}



- (void)enumerateEventGroups:(GroupsDelegate *)delegate {
    if (!delegate) {
        return;
    }
    
    NSArray *events = [self allEvents];
    NSDate *curDate = nil;
    uint groupIndex = 0;
    
    for (Event *event in events) {
        NSDate *date = event.date;
        
        if (curDate && [DingoUtilites daysBetween:curDate and:date]) {
            groupIndex++;
        }
        
        curDate = date;
        (*delegate)(event, groupIndex);
    }
}

- (void)enumerateFeaturedEventGroups:(GroupsDelegate *)delegate {
    if (!delegate) {
        return;
    }
    
    NSArray *events = [self featuredEvents];
    NSDate *curDate = nil;
    uint groupIndex = 0;
    
    for (Event *event in events) {
        NSDate *date = event.date;
        
        if (curDate && [DingoUtilites daysBetween:curDate and:date]) {
            groupIndex++;
        }
        
        curDate = date;
        (*delegate)(event, groupIndex);
    }
}


- (void)enumerateEventGroups:(GroupsDelegate *)delegate categories:(NSArray*)categories {
    if (!delegate) {
        return;
    }
    
    NSArray *events = [self allEvents];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id IN %@", categories];
    events = [events filteredArrayUsingPredicate:predicate];
    
    NSDate *curDate = nil;
    uint groupIndex = 0;
    
    for (Event *event in events) {
        NSDate *date = event.date;//dict[@"begin"];
        
        if (curDate && [DingoUtilites daysBetween:curDate and:date]) {
            groupIndex++;
        }
        
        curDate = date;
        
        (*delegate)(event, groupIndex);
    }
    
}


- (void)enumerateOffersGroups:(GroupsDelegate *)delegate {
    if (!delegate) {
        return;
    }
    
    NSArray *offers = [self allOffers];
    NSString *curEvent = nil;
    uint groupIndex = 0;
    
    for (NSDictionary *dict in offers) {
        NSString *event = dict[@"event"];
        
        if (curEvent && ![curEvent isEqualToString:event]) {
            groupIndex++;
        }
        
        curEvent = event;
        (*delegate)(dict, groupIndex);
    }
}

#pragma mark Messages

- (void)fetchMessagesWithCompletion:( void (^) (BOOL finished))handler {
//    
//    [WebServiceManager receiveMessages:@{@"conversations": @"true"} completion:^(id response, NSError *error) {
//        if (response[@"messages"]) {
//            NSArray *messages = response[@"messages"];
//            
//            // remove deleted tickets from local database
//            NSArray *messagesIDs = [messages valueForKey:@"id"];
//            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
//            request.predicate = [NSPredicate predicateWithFormat:@"NOT (message_id IN %@)", messagesIDs];
//            
//            NSArray *messagesToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
//            if (messagesToRemove.count) {
//                for (Message *toRemove in messagesToRemove) {
//                    [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
//                }
//            }
//            
//            for (NSDictionary *message in messages) {
//                [self addOrUpdateMessage:message];
//            }
//            
//            [[AppManager sharedManager] saveContext];
//        }
//        handler(YES);
//    }];
    
    [[CommonDocUnAuth sharedDocument] getPath:@"messages" parameters:@{@"conversations": @"true"} success:^(AFHTTPRequestOperation *operation, id response) {
        if (response[@"messages"]) {
                        NSArray *messages = response[@"messages"];
            
                        // remove deleted tickets from local database
                        NSArray *messagesIDs = [messages valueForKey:@"id"];
                        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
                        request.predicate = [NSPredicate predicateWithFormat:@"NOT (message_id IN %@)", messagesIDs];
            
                        NSArray *messagesToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
                        if (messagesToRemove.count) {
                            for (Message *toRemove in messagesToRemove) {
                                [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
                            }
                        }
            
                        for (NSDictionary *message in messages) {
                            [self addOrUpdateMessage:message];
                        }
                        
                        [[AppManager sharedManager] saveContext];
                    }
                    handler(YES);
    
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       handler(YES);
    }];
}

- (NSInteger)unreadMessagesCount {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    request.predicate = [NSPredicate predicateWithFormat:@"read == 0 && receiver_id == %@", [AppManager sharedManager].userInfo[@"id"]];
    
    NSArray *messages = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    return [messages count];
}

- (NSInteger)unreadMessagesCountForTicket:(NSString *)ticketID {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    request.predicate = [NSPredicate predicateWithFormat:@"read == 0 && receiver_id == %@ && conversation_id == %@", [AppManager sharedManager].userInfo[@"id"], ticketID];
    
    NSArray *messages = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    return [messages count];
}

- (void)addOrUpdateMessage:(NSDictionary *)info {
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    
    NSString *messageID = info[@"id"];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    request.predicate = [NSPredicate predicateWithFormat:@"message_id == %@", messageID];
    
    NSError *error = nil;
    Message *message = nil;
    NSArray *messages = [context executeFetchRequest:request error:&error];
    if (messages.count > 0) {
        message = messages[0];
    } else {
        message = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:context];
        message.message_id = messageID;
    }
    
    
    message.content = info[@"content"];
    message.sender_id = [info[@"sender_id"] stringValue];
    message.sender_avatar_url = info[@"sender_avatar"];
    message.sender_name = info[@"sender_name"];
    
    message.receiver_id = [info[@"receiver_id"] stringValue];
    message.receiver_avatar_url = info[@"receiver_avatar"];
    message.receiver_name = info[@"receiver_name"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ";
    
    NSDate *date = [formatter dateFromString:info[@"datetime"]];
    
    message.datetime = date;
    
    message.from_dingo = @( [info[@"from_dingo"] boolValue]);
    message.read = @( [info[@"read"] boolValue]);
    message.offer_new = @( [info[@"new_offer"] boolValue]);
    message.ticket_id = ![info[@"ticket_id"] isKindOfClass:[NSNull class]] ? info[@"ticket_id"] : @"";
    message.conversation_id=[info objectForKey:@"conversation_id"];
    
    if (![info[@"offer_id"] isKindOfClass:[NSNull class]]) {
        message.offer_id = info[@"offer_id"];
    }

}

- (NSArray *)allMessages{
    
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    return events;
}

- (NSArray *)allMessagesFor:(NSNumber *)userID ticketID:(NSString*)ticketID {
    
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    request.predicate = [NSPredicate predicateWithFormat:@"(receiver_id == %@ || (sender_id == %@ && from_dingo != 1))  && ticket_id == %@ ", [userID stringValue], [userID stringValue], ticketID];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    return events;
}

-(NSArray *)allMessagesForConversatinID:(NSNumber*)userID conersationId:(NSString *)conversId;{
    NSManagedObjectContext *context=[AppManager sharedManager].managedObjectContext;
//    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Messages"];
//    request.predicate=[NSPredicate predicateWithFormat:@"(conversation_id == %@)",conversId];
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    request.predicate = [NSPredicate predicateWithFormat:@"(receiver_id == %@ || (sender_id == %@ && from_dingo != 1))  && conversation_id == %@ ", [userID stringValue], [userID stringValue], conversId];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];

    NSError *eror=nil;
    NSArray *messages=[context executeFetchRequest:request error:&eror];
    return messages;
}

-(BOOL)willShowDingoAvatar:(NSString *)ticketID{
    BOOL willShowDingoAvatar=false;
     NSArray* msgArray = [[DataManager shared] allMessagesFor:[AppManager sharedManager].userInfo[@"id"] ticketID:ticketID];
        NSArray *arrayMessage_fromDingo=[msgArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"from_dingo == %@",[NSNumber numberWithBool:true]]];
    if (msgArray.count == arrayMessage_fromDingo.count)
        willShowDingoAvatar=true;
    else
        willShowDingoAvatar=false;
    return willShowDingoAvatar;
}

-(NSString *)returnAvatarUrl:(NSString *)tickId :(NSString *)usrID{
    NSString *avatar_url=@"";
    NSArray* msgArray = [[DataManager shared] allMessagesFor:[AppManager sharedManager].userInfo[@"id"] ticketID:tickId];
    NSArray *arrayMessage_fromDingo=[msgArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sender_id == %@ && from_dingo == %@",usrID,[NSNumber numberWithBool:false]]];
    
    if ([arrayMessage_fromDingo count]) {
        Message *msgObject=[arrayMessage_fromDingo objectAtIndex:0];
        avatar_url=msgObject.sender_avatar_url;
    }
    return avatar_url;
}

-(BOOL)directMessageFromDingo{
    BOOL isDingomessage=false;
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    request.predicate = [NSPredicate predicateWithFormat:@"((sender_id == %@ AND ticket_id = nil) ||(receiver_id == %@ AND ticket_id = nil))  ", [[AppManager sharedManager].userInfo[@"id"] stringValue], [[AppManager sharedManager].userInfo[@"id"] stringValue]];
   
    NSError *error = nil;
    
     NSArray* msgArray = [[DataManager shared] allMessagesFor:[AppManager sharedManager].userInfo[@"id"] ticketID:nil];
    NSArray *events = [context executeFetchRequest:request error:&error];
    if ([msgArray count] == [events count] && [msgArray count]) {
        isDingomessage=true;
    }

    return isDingomessage;
}

#pragma mark Alerts 

- (NSArray *)allAlerts {
    
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Alerts"];
    request.predicate = [NSPredicate predicateWithFormat:@"on == 1"];
    //    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    NSError *error = nil;
    NSArray *alerts = [context executeFetchRequest:request error:&error];
    
    return alerts;
}

- (void)allAlertsWithCompletion:( void (^) (BOOL finished))handler {
//    [WebServiceManager userAlerts:nil completion:^(id response, NSError *error) {
//        if (!error) {
//            if (response) {
//                NSArray *alerts = response[@"alerts"];
//                
//                // remove deleted alerts from local database
//                NSArray *alertIDs = [alerts valueForKey:@"id"];
//                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Alerts"];
//                request.predicate = [NSPredicate predicateWithFormat:@"NOT (alert_id IN %@)", alertIDs];
//                
//                NSArray *alertsToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
//                if (alertsToRemove.count) {
//                    for (Alert *toRemove in alertsToRemove) {
//                        [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
//                    }
//                }
//
//                for (NSDictionary *info in alerts) {
//                    [self addOrUpdateAlert:info];
//                }
//                
//                [[AppManager sharedManager] saveContext];
//                handler(true);
//            }
//        }
//    }];
    
    [[CommonDocUnAuth sharedDocument] getPath:@"alerts" parameters:nil success:^(AFHTTPRequestOperation *operation, id response) {
               
                    if (response) {

                        dispatch_queue_t main_queue = dispatch_get_main_queue();
                        dispatch_queue_t request_queue = dispatch_queue_create("com.app.request", NULL);
                        
                        
                                                dispatch_async(request_queue, ^{
                                                    NSArray *alerts = response[@"alerts"];
                                                    
                                                    // remove deleted alerts from local database
                                                    NSArray *alertIDs = [alerts valueForKey:@"id"];
                                                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Alerts"];
                                                    request.predicate = [NSPredicate predicateWithFormat:@"NOT (alert_id IN %@)", alertIDs];
                                                    
                                                    NSArray *alertsToRemove = [[AppManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
                                                    if (alertsToRemove.count) {
                                                        for (Alert *toRemove in alertsToRemove) {
                                                            [[AppManager sharedManager].managedObjectContext deleteObject:toRemove];
                                                        }
                                                    }
                                                    
                                                    for (NSDictionary *info in alerts) {
                                                        [self addOrUpdateAlert:info];
                                                    }
                                                    

                            
                            dispatch_sync(main_queue, ^{
                                [[AppManager sharedManager] saveContext];
                                 handler(true);
                            });
                        });
                        
                       
                    }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         handler(true);
    }];
}

- (void)addOrUpdateAlert:(NSDictionary *)info {
    NSManagedObjectContext *context = [AppManager sharedManager].managedObjectContext;
    
    NSString *alert_id = info[@"id"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Alerts"];
    request.predicate = [NSPredicate predicateWithFormat:@"alert_id == %@", alert_id];
    
    NSError *error = nil;
    Alert *alert = nil;
    NSArray *alerts = [context executeFetchRequest:request error:&error];
    if (alerts.count > 0) {
        alert = alerts[0];
    } else {
        alert = [NSEntityDescription insertNewObjectForEntityForName:@"Alerts" inManagedObjectContext:context];
        alert.alert_id = alert_id;
    }
    
    alert.event_id = info[@"event_id"];
    alert.alert_description = info[@"description"];
    if (info[@"on"]) {
        alert.on = @( [info[@"on"] boolValue]);
    } else {
        alert.on = @YES;
    }
    
}


@end
