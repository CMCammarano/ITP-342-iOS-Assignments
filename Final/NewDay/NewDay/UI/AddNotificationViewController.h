//
//  AddNotificationViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^AddNotificationHandler) (Notification* block);

@interface AddNotificationViewController : UITableViewController<UIPopoverPresentationControllerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (copy, nonatomic) AddNotificationHandler completionHandler;
	@property (strong, nonatomic) Notification* notificationToEdit;
@end
