//
//  AddViewController.h
//  Lab5
//
//  Created by Colin Cammarano on 4/7/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>

// Completion Handler typedef
typedef void(^AddFlashcardCompletionHandler) (NSString* question, NSString* answer);

@interface AddViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

	// Public properties
	@property (strong, nonatomic) NSString* questionText;
	@property (strong, nonatomic) NSString* answerText;
	@property (strong, nonatomic) NSString* labelText;
	@property (strong, nonatomic) NSString* placeholderText;

	// Callbacks
	@property (copy, nonatomic) AddFlashcardCompletionHandler completionHandler;
@end
