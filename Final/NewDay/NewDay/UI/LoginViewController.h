//
//  LoginViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/2/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>

/**************************************/
// COMPLETION HANDLER
/**************************************/
typedef void(^LoginCompletionHandler)();

@interface LoginViewController : UIViewController <UITextFieldDelegate>
	/**************************************/
	// COMPLETION HANDLER
	/**************************************/
	@property (copy, nonatomic) LoginCompletionHandler completionHandler;
@end
