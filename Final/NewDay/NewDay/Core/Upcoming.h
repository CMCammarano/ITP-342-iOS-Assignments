//
//  Upcoming.h
//  NewDay
//
//  Created by Colin Cammarano on 4/28/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entry.h"

@interface Upcoming : NSObject
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (strong, nonatomic) NSString* title;
	@property (strong, nonatomic) NSDate* date;
	@property (strong, nonatomic) Entry* entry;
	@property NSUInteger category;

	/**************************************/
	// PUBLIC MEMBER METHODS
	/**************************************/
	- (instancetype) init;
	+ (instancetype) upcomingFromEntry: (Entry*) entry;
@end
