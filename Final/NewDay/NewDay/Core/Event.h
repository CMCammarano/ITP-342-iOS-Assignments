//
//  Event.h
//  NewDay
//
//  Created by Colin Cammarano on 4/29/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "Entry.h"

@interface Event : Entry
	/**************************************/
	// SINGLETON
	/**************************************/
	@property (strong, nonatomic) NSDate* end;
@end
