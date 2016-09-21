//
//  Quote.h
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quote : NSObject
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (strong, nonatomic) NSString* quote;
	@property (strong, nonatomic) NSString* author;

	/**************************************/
	// PUBLIC MEMBER METHODS
	/**************************************/
	+ (instancetype) quoteFromQuote:(NSString*) quote withAuthor:(NSString*) author;
@end
