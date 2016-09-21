//
//  RegisterViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/2/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^RegisterCompletionHandler) ();

@interface RegisterViewController : UIViewController <UITextFieldDelegate>
	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (copy, nonatomic) RegisterCompletionHandler completionHandler;
@end
