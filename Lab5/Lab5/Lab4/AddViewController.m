//
//  AddViewController.m
//  Lab5
//
//  Created by Colin Cammarano on 4/7/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController () <UITextFieldDelegate, UITextViewDelegate>

	// IB Outlets
	@property (weak, nonatomic) IBOutlet UIBarButtonItem* buttonSave;
	@property (weak, nonatomic) IBOutlet UIBarButtonItem* buttonCancel;
	@property (weak, nonatomic) IBOutlet UITextView* textViewQuestion;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldAnswer;
	@property (weak, nonatomic) IBOutlet UILabel* labelPrompt;

	// Private member methods
	- (BOOL)textFieldShouldReturn:(UITextField*) textField;
	- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string;
	- (void)enableSaveButton;
@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Do any additional setup after loading the view.
	[self enableSaveButton];
	self.textFieldAnswer.delegate = self;
	
	self.labelText = @"Please enter a question in the text view!";
	self.placeholderText = @"Please enter an answer in the text field!";
	
	self.labelPrompt.text = self.labelText;
	self.textFieldAnswer.placeholder = self.placeholderText;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//[self.textFieldAnswer becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Text Field
- (BOOL)textFieldShouldReturn:(UITextField*) textField {
	self.answerText = self.textFieldAnswer.text;
	self.questionText = self.textViewQuestion.text;
	
	[self enableSaveButton];
	[self.textFieldAnswer resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	self.answerText = [textField.text stringByReplacingCharactersInRange: range withString: string];
	self.questionText = self.textViewQuestion.text;
	
	[self enableSaveButton];
	return YES;
}

// Save button
- (void)enableSaveButton {
	self.buttonSave.enabled = self.questionText.length > 0 && self.answerText.length > 0;
}

- (IBAction)onSaveButtonPressed:(id)sender {
	[self.textViewQuestion resignFirstResponder];
	[self.textFieldAnswer resignFirstResponder];
	
	if (self.completionHandler) {
		self.completionHandler (self.questionText, self.answerText);
	}
	
	self.textFieldAnswer.text = nil;
	self.textViewQuestion.text = nil;
}

// Cancel button
- (IBAction)onCancelButtonPressed:(id)sender {
	[self.textViewQuestion resignFirstResponder];
	[self.textFieldAnswer resignFirstResponder];
	
	if (self.completionHandler) {
		self.completionHandler (nil, nil);
	}
	
	self.textFieldAnswer.text = nil;
	self.textViewQuestion.text = nil;
}

// Misc
- (void)touchesBegan:(NSSet<UITouch*>*) touches withEvent:(UIEvent*) event {
	[self.textViewQuestion resignFirstResponder];
	[self.textFieldAnswer resignFirstResponder];
	
	[self enableSaveButton];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
