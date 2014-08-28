//
//  DataManager.h
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//


#import "EventCategory.h"
#import "Event.h"
#import "Ticket.h"
#import "Alert.h"

@interface DataManager : NSObject

+ (DataManager *)shared;
+ (NSString*)generateGUID;

- (NSArray *)allEvents;
- (NSArray *)allAlerts;
- (NSArray *)featuredEvents;
- (void)allEventsWithCompletion:( void (^) (BOOL finished))handler;
- (NSUInteger)eventsDateRange;
- (NSArray *)eventsBeforeDate:(NSDate *)date;
- (NSArray *)eventsAfterDate:(NSDate *)date;
+ (NSString *)eventLocation:(Event *)data;
- (Event*)eventByID:(NSString*)eventID;

- (NSUInteger)eventsGroupsCount;
- (NSUInteger)featuredEventsGroupsCount;
- (NSUInteger)eventsGroupsCountForCategories:(NSArray*)categories;

- (NSUInteger)eventsCountWithGroupIndex:(NSUInteger)group;
- (NSUInteger)featuredEventsCountWithGroupIndex:(NSUInteger)group;
- (NSUInteger)eventsCountWithGroupIndex:(NSUInteger)group categories:(NSArray*)categories;

- (Event *)eventDescriptionByIndexPath:(NSIndexPath *)path;
- (Event *)featuredEventDescriptionByIndexPath:(NSIndexPath *)path;
- (Event *)eventDescriptionByIndexPath:(NSIndexPath *)path categories:(NSArray*)categories;

- (NSDate *)eventGroupDateByIndex:(NSUInteger)groupIndex;
- (NSDate *)featuredEventGroupDateByIndex:(NSUInteger)groupIndex;
- (NSDate *)eventGroupDateByIndex:(NSUInteger)groupIndex categories:(NSArray*)categories;

- (NSArray *)allTicketsByEventID:(NSString *)eventID;
- (void)allTicketsByEventID:(NSString *)eventID completion:( void (^) (BOOL finished))handler;
- (NSArray *)userTickets;
- (void)userTicketsWithCompletion:( void (^) (BOOL finished))handler;
- (NSArray *)ticketsBeforeDate:(NSDate *)date;
- (NSArray *)ticketsAfterDate:(NSDate *)date;

- (NSArray *)allFriends;
- (NSArray *)allCities;

- (NSUInteger)offersGroupsCount;
- (NSUInteger)offersCountWithGroupIndex:(NSUInteger)group;
- (NSDictionary *)offerDescriptionByIndexPath:(NSIndexPath *)path;
- (NSString *)offersGroupTitleByIndex:(NSUInteger)groupIndex;

- (NSArray *)allCategories;
- (void)allCategoriesWithCompletion:( void (^) (BOOL finished))handler;
- (EventCategory *)dataByCategoryName:(NSString *)name;
- (EventCategory *)dataByCategoryID:(NSString *)categoryID;
- (NSUInteger)categoryIndexByName:(NSString *)name;

- (void)save;
- (void)addOrUpdateAlert:(NSDictionary *)info;
@end
