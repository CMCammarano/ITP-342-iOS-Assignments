//
//  Alert.m
//  NewDay
//
//  Created by Colin Cammarano on 5/6/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "Alert.h"

@implementation Alert

+ (instancetype) alertWithTitle:(NSString*) title withTime:(NSInteger) time {
	Alert* retVal = [[Alert alloc] init];
	retVal.title = title;
	retVal.delay = time;
	return retVal;
}
@end
