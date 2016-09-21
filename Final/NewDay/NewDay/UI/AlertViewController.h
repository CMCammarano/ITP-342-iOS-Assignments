//
//  AlertViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/5/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^AlertCompletionHandler) (NSInteger alert);

@interface AlertViewController : UITableViewController
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (copy, nonatomic) AlertCompletionHandler completionHandler;
@end
