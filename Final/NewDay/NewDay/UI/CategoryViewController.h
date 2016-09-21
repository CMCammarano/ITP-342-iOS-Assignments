//
//  CategoryViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/3/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^CategoryCompletionHandler) (NSInteger category);

@interface CategoryViewController : UITableViewController
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (copy, nonatomic) CategoryCompletionHandler completionHandler;
@end
