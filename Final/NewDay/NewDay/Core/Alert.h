//
//  Alert.h
//  NewDay
//
//  Created by Colin Cammarano on 5/6/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alert : NSObject
	@property (strong, nonatomic) NSString* title;
	@property NSInteger delay;

	+ (instancetype) alertWithTitle:(NSString*) title withTime:(NSInteger) time;
@end
