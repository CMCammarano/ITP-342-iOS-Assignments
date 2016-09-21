//
//  AddBlockViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Block.h"

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^AddBlockHandler) (Block* block);

@interface AddBlockViewController : UITableViewController <UIPopoverPresentationControllerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (copy, nonatomic) AddBlockHandler completionHandler;
	@property (strong, nonatomic) Block* blockToEdit;
@end
