//
//  DataManager.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DataManager.h"

#import "DingoUtilites.h"

typedef void (^GroupsDelegate)(NSDictionary *eventDescription, NSUInteger groupIndex);

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

- (NSArray *)allEvents {
    static NSArray *events = nil;
    if (events) {
        return events;
    }
    
    events = [self loadRecordsFromPlist:@"events"];
    return events;
}

- (NSUInteger)eventsDateRange {
    NSArray *events = [self allEvents];
    BOOL before = NO;
    BOOL after = NO;
    
    for (NSDictionary *dict in events) {
        NSDate *date = dict[@"begin"];
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
    
    for (NSDictionary *dict in events) {
        NSDate *curDate = dict[@"begin"];
        if ([DingoUtilites daysBetween:curDate and:date] > 0) {
            [result addObject:dict];
        }
    }
    
    return [result copy];
}

- (NSArray *)eventsAfterDate:(NSDate *)date {
    NSArray *events = [self allEvents];
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSDictionary *dict in events) {
        NSDate *curDate = dict[@"begin"];
        if ([DingoUtilites daysBetween:date and:curDate] >= 0) {
            [result addObject:dict];
        }
    }
    
    return [result copy];
}

- (NSUInteger)eventsGroupsCount {
    __block NSUInteger groupsCount = 0;
    GroupsDelegate delegate = ^(NSDictionary *eventDescription, NSUInteger groupIndex) {
        if (groupIndex > groupsCount) {
            groupsCount = groupIndex;
        }
    };
    
    [self enumerateEventGroups:&delegate];
    return groupsCount + 1;
}

- (NSUInteger)eventsCountWithGroupIndex:(NSUInteger)group {
    __block NSUInteger eventsCount = 0;
    GroupsDelegate delegate = ^(NSDictionary *eventDescription, NSUInteger groupIndex) {
        if (groupIndex == group) {
            eventsCount++;
        }
    };
    
    [self enumerateEventGroups:&delegate];
    return eventsCount;
}

- (NSDictionary *)eventDescriptionByIndexPath:(NSIndexPath *)path {
    __block uint eventsIndex = 0;
    __block NSDictionary *dict = nil;
    GroupsDelegate delegate = ^(NSDictionary *eventDescription, NSUInteger groupIndex) {
        if (groupIndex != path.section) {
            return;
        }
        
        if (eventsIndex++ != path.row) {
            return;
        }
        
        dict = eventDescription;
    };
    
    [self enumerateEventGroups:&delegate];
    return dict;
}

- (NSDate *)eventGroupDateByIndex:(NSUInteger)groupIndex {
    __block NSDate *date = nil;
    GroupsDelegate delegate = ^(NSDictionary *eventDescription, NSUInteger grIndx) {
        if (groupIndex != grIndx) {
            return;
        }
        
        date = eventDescription[@"begin"];
    };
    
    [self enumerateEventGroups:&delegate];
    return date;
}

#pragma mark - Other Requests

- (NSArray *)allTicketsByEventName:(NSString *)name {
    NSArray *events = [self allEvents];
    NSMutableArray *tickets = [NSMutableArray array];
    for (NSDictionary *dict in events) {
        if ([name isEqualToString:dict[@"name"]]) {
            [tickets addObject:dict];
        }
    }
    
    return [tickets copy];
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
    static NSArray *categories = nil;
    if (categories) {
        return categories;
    }
    
    categories = [self loadRecordsFromPlist:@"categories"];
    return categories;
}

- (NSDictionary *)dataByCategoryName:(NSString *)name {
    NSArray *cats = [self allCategories];
    for (NSDictionary *dict in cats) {
        if ([name isEqualToString:dict[@"name"]]) {
            return dict;
        }
    }
    
    return nil;
}

- (NSUInteger)categoryIndexByName:(NSString *)name {
    NSArray *cats = [[DataManager shared] allCategories];
    NSUInteger index = 0;
    for (NSDictionary *dict in cats) {
        if ([name isEqualToString:dict[@"name"]]) {
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

- (void)enumerateEventGroups:(GroupsDelegate *)delegate {
    if (!delegate) {
        return;
    }
    
    NSArray *events = [self allEvents];
    NSDate *curDate = nil;
    uint groupIndex = 0;
    
    for (NSDictionary *dict in events) {
        NSDate *date = dict[@"begin"];
        
        if (curDate && [DingoUtilites daysBetween:curDate and:date]) {
            groupIndex++;
        }
        
        curDate = date;
        (*delegate)(dict, groupIndex);
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

@end
