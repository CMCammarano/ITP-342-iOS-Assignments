//
//  LoginViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/2/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "LoginViewController.h"
#import "ApplicationManager.h"

@interface LoginViewController ()
	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (weak, nonatomic) IBOutlet UITextField* textFieldEmail;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldPassword;
	@property (weak, nonatomic) IBOutlet UIButton* buttonLogin;

	@property (strong, nonatomic) ApplicationManager* manager;
@end

@implementation LoginViewController

/**************************************/
// PRIVATE MEMBER METHODS
/**************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Do any additional setup after loading the view.
	self.manager = [ApplicationManager instance];
	
	[self enableLoginButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Button Actions
- (IBAction)onLogin:(id)sender {
	
	// Resign all responders
	[self resignResponders];
	
	// Attempt login
	NSString* email = self.textFieldEmail.text;
	NSString* password = self.textFieldPassword.text;
	[self.manager loginUser:email withPassword:password withBlock:^(void) {
		if (self.completionHandler) {
			self.completionHandler ();
		}
		
		// Clear the fields
		[self clearFields];
	}];
}

- (IBAction)onRegister:(id)sender {
	
	// Resign all responders
	[self resignResponders];
	
	// Clear the fields
	[self clearFields];
}

- (IBAction)onCancel:(id)sender {
	
	// Resign all responders
	[self resignResponders];
	
	// Fire the completion handler
	if (self.completionHandler) {
		self.completionHandler ();
	}
	
	// Clear the fields
	[self clearFields];
}

// Text Fields
- (BOOL)textFieldShouldReturn:(UITextField*) textField {
	[self enableLoginButton];
	[self.textFieldEmail resignFirstResponder];
	[self.textFieldPassword resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	[self enableLoginButton];
	return YES;
}

- (void)touchesBegan:(NSSet<UITouch*>*) touches withEvent:(UIEvent*) event {
	[self.textFieldEmail resignFirstResponder];
	[self.textFieldPassword resignFirstResponder];
	[self enableLoginButton];
}

// Misc
- (void) enableLoginButton {
	self.buttonLogin.enabled = self.textFieldEmail.text.length > 0 && self.textFieldPassword.text.length > 0;
}

- (void) resignResponders {
	[self.textFieldEmail resignFirstResponder];
	[self.textFieldPassword resignFirstResponder];
}

- (void) clearFields {
	self.textFieldEmail.text = nil;
	self.textFieldPassword.text = nil;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	if ([[segue identifier] isEqualToString:@"registerSegue"]) {
		LoginViewController* login = segue.destinationViewController.childViewControllers.firstObject;
		login.completionHandler = ^() {
			[self dismissViewControllerAnimated:YES completion:nil];
			
			// Clear the fields
			[self clearFields];
		};
	}
}

@end
