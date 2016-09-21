//
//  User.h
//  NewDay
//
//  Created by Colin Cammarano on 4/28/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (strong, nonatomic) NSString* uid;
	@property (strong, nonatomic) NSString* name;
	@property (strong, nonatomic) NSString* username;
	@property (strong, nonatomic) NSString* email;
	@property (strong, nonatomic) NSData* password;
@end
