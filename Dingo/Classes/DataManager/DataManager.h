//
//  DataManager.h
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

@interface DataManager : NSObject

+ (DataManager *)shared;

- (NSArray *)allEvents;
- (NSUInteger)eventsDateRange;
- (NSArray *)eventsBeforeDate:(NSDate *)date;
- (NSArray *)eventsAfterDate:(NSDate *)date;

- (NSUInteger)eventsGroupsCount;
- (NSUInteger)eventsCountWithGroupIndex:(NSUInteger)group;
- (NSDictionary *)eventDescriptionByIndexPath:(NSIndexPath *)path;
- (NSDate *)eventGroupDateByIndex:(NSUInteger)groupIndex;

- (NSArray *)allTicketsByEventName:(NSString *)name;
- (NSArray *)allFriends;
- (NSArray *)allCities;

- (NSUInteger)offersGroupsCount;
- (NSUInteger)offersCountWithGroupIndex:(NSUInteger)group;
- (NSDictionary *)offerDescriptionByIndexPath:(NSIndexPath *)path;
- (NSString *)offersGroupTitleByIndex:(NSUInteger)groupIndex;

- (NSArray *)allCategories;
- (NSDictionary *)dataByCategoryName:(NSString *)name;
- (NSUInteger)categoryIndexByName:(NSString *)name;

@end
