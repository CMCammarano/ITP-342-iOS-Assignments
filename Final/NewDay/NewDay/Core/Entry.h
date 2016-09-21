//
//  Entry.h
//  NewDay
//
//  Created by Colin Cammarano on 4/29/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entry : NSObject
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (strong, nonatomic) NSString* uid;
	@property (strong, nonatomic) NSString* title;
	@property (strong, nonatomic) NSDate* start;
	@property NSUInteger category;
	@property NSUInteger alert;
@end
