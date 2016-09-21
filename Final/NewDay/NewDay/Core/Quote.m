//
//  Quote.m
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "Quote.h"

@implementation Quote

+ (instancetype) quoteFromQuote:(NSString*) quote withAuthor:(NSString*) author {
	Quote* retVal = [[Quote alloc] init];
	retVal.quote = quote;
	retVal.author = author;
	return retVal;
}
@end
