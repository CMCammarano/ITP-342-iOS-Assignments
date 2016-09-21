//
//  Category.h
//  NewDay
//
//  Created by Colin Cammarano on 5/3/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Category : NSObject

	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (strong, nonatomic) UIColor* color;
	@property (strong, nonatomic) NSString* name;

	/**************************************/
	// PUBLIC MEMBER METHODS
	/**************************************/
	+ (instancetype) categoryFromColor:(UIColor*) color withName:(NSString*) name;
@end
