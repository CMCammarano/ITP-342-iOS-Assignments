//
//  Block.h
//  NewDay
//
//  Created by Colin Cammarano on 4/29/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "Entry.h"

@interface Block : Entry
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (strong, nonatomic) NSDate* end;
	@property (strong, nonatomic) NSIndexSet* days;
@end
