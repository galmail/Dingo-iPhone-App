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

@interface DataManager : NSObject

+ (DataManager *)shared;

- (NSArray *)allEvents;
- (NSArray *)featuredEvents;
- (void)allEventsWithCompletion:( void (^) (BOOL finished))handler;
- (NSUInteger)eventsDateRange;
- (NSArray *)eventsBeforeDate:(NSDate *)date;
- (NSArray *)eventsAfterDate:(NSDate *)date;
+ (NSString *)eventLocation:(Event *)data;

- (NSUInteger)eventsGroupsCount;
- (NSUInteger)eventsGroupsCountForCategories:(NSArray*)categories;
- (NSUInteger)eventsCountWithGroupIndex:(NSUInteger)group;
- (Event *)eventDescriptionByIndexPath:(NSIndexPath *)path;
- (NSDate *)eventGroupDateByIndex:(NSUInteger)groupIndex;

- (NSArray *)allTicketsByEventName:(NSString *)name;
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

@end
