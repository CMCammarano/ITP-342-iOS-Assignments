//
//  Category.m
//  NewDay
//
//  Created by Colin Cammarano on 5/3/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "Category.h"

@implementation Category

/**************************************/
// PUBLIC MEMBER METHODS
/**************************************/
+ (instancetype) categoryFromColor:(UIColor*) color withName:(NSString*) name {
	Category* category = [[Category alloc] init];
	category.color = color;
	category.name = name;
	return category;
}

@end
