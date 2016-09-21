//
//  TimePickerViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/1/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^AddDateCompletionHandler) (NSDate* date);

@interface TimePickerViewController : UIViewController
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (copy, nonatomic) AddDateCompletionHandler completionHandler;
	@property (strong, nonatomic) NSDate* date;
@end
