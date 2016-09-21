//
//  RegisterViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/2/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "RegisterViewController.h"
#import "ApplicationManager.h"

@interface RegisterViewController ()

	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (weak, nonatomic) IBOutlet UITextField* textFieldName;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldUsername;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldEmail1;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldEmail2;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldPassword1;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldPassword2;
	@property (weak, nonatomic) IBOutlet UIButton* buttonSignUp;

	@property (strong, nonatomic) ApplicationManager* manager;

	/**************************************/
	// PRIVATE MEMBER METHODS
	/**************************************/
	- (void)enableSignUp;
	- (void)resignResponders;
	- (void)clearFields;
@end

@implementation RegisterViewController

/**************************************/
// PRIVATE MEMBER METHODS
/**************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Do any additional setup after loading the view.
	self.manager = [ApplicationManager instance];
	
	// Disable the sign up button
	[self enableSignUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Buttons
- (IBAction)onSignUp:(id)sender {

	// Resign all responders
	[self resignResponders];
	
	// Attempt login
	NSString* name = self.textFieldName.text;
	NSString* username = self.textFieldUsername.text;
	NSString* email = self.textFieldEmail1.text;
	NSString* password = self.textFieldPassword1.text;
	[self.manager registerUser:name withUsername:username withEmail:email withPassword:password withBlock:^{
		
		// Clear the fields
		[self clearFields];
		
		// Segue!
		[self performSegueWithIdentifier:@"finishRegisterSegue" sender:self];
	}];
}

- (IBAction)onCancel:(id)sender {
	
	// Resign responders
	[self resignResponders];
	
	if (self.completionHandler) {
		self.completionHandler ();
	}
	
	// Clean up text fields
	[self clearFields];
}

// Text Fields
- (BOOL)textFieldShouldReturn:(UITextField*) textField {
	
	if ([self.textFieldName isFirstResponder]) {
		[self.textFieldName resignFirstResponder];
		[self.textFieldUsername becomeFirstResponder];
	}
	
	else if ([self.textFieldUsername isFirstResponder]) {
		[self.textFieldUsername resignFirstResponder];
		[self.textFieldEmail1 becomeFirstResponder];
	}
	
	else if ([self.textFieldEmail1 isFirstResponder]) {
		[self.textFieldEmail1 resignFirstResponder];
		[self.textFieldEmail2 becomeFirstResponder];
	}
	
	else if ([self.textFieldEmail2 isFirstResponder]) {
		[self.textFieldEmail2 resignFirstResponder];
		[self.textFieldPassword1 becomeFirstResponder];
	}
	
	else if ([self.textFieldPassword1 isFirstResponder]) {
		[self.textFieldPassword1 resignFirstResponder];
		[self.textFieldPassword2 becomeFirstResponder];
	}
	
	else {
		[self resignResponders];
	}
	
	[self enableSignUp];
	return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	[self enableSignUp];
	return YES;
}

- (void)touchesBegan:(NSSet<UITouch*>*) touches withEvent:(UIEvent*) event {
	[self resignResponders];
	[self enableSignUp];
}

// Misc
- (void)enableSignUp {
	
	if (self.textFieldName.text.length == 0
		|| self.textFieldUsername.text.length == 0
		|| self.textFieldEmail1.text.length == 0
		|| self.textFieldEmail2.text.length == 0
		|| self.textFieldPassword1.text.length == 0
		|| self.textFieldPassword2.text.length == 0) {
		self.buttonSignUp.enabled = NO;
	}
	
	else if (![self.textFieldEmail1.text isEqualToString:self.textFieldEmail2.text]) {
		self.buttonSignUp.enabled = NO;
	}
	
	else if (![self.textFieldPassword1.text isEqualToString:self.textFieldPassword2.text]) {
		self.buttonSignUp.enabled = NO;
	}
	
	else {
		self.buttonSignUp.enabled = YES;
	}
}

- (void)resignResponders {
	[self.textFieldName resignFirstResponder];
	[self.textFieldUsername resignFirstResponder];
	[self.textFieldEmail1 resignFirstResponder];
	[self.textFieldEmail2 resignFirstResponder];
	[self.textFieldPassword1 resignFirstResponder];
	[self.textFieldPassword2 resignFirstResponder];
}

- (void)clearFields {
	self.textFieldName.text = nil;
	self.textFieldUsername.text = nil;
	self.textFieldEmail1.text = nil;
	self.textFieldEmail2.text = nil;
	self.textFieldPassword1.text = nil;
	self.textFieldPassword2.text = nil;
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
