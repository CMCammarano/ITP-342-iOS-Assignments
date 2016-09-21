//
//  Upcoming.m
//  NewDay
//
//  Created by Colin Cammarano on 4/28/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "Upcoming.h"

@interface Upcoming ()

@end

@implementation Upcoming
/**************************************/
// PUBLIC MEMBER METHODS
/**************************************/
- (instancetype) init {
	self = [super init];
	return self;
}

+ (instancetype) upcomingFromEntry: (Entry*) entry {
	Upcoming* retVal = [[Upcoming alloc] init];
	retVal.entry = entry;
	retVal.title = entry.title;
	retVal.date = entry.start;
	retVal.category = entry.category;
	
	return retVal;
}

@end
