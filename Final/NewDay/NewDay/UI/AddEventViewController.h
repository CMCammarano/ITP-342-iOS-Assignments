//
//  AddEventViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/1/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^AddEventHandler) (Event* event);

@interface AddEventViewController : UITableViewController <UIPopoverPresentationControllerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (copy, nonatomic) AddEventHandler completionHandler;
	@property (strong, nonatomic) Event* eventToEdit;

@end
