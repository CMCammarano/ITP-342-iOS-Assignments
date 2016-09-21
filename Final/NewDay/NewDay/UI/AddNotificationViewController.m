//
//  AddNotificationViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "AddNotificationViewController.h"
#import "TimePickerViewController.h"
#import "CategoryViewController.h"
#import "AlertViewController.h"
#import "ApplicationManager.h"

@interface AddNotificationViewController ()
	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (strong, nonatomic) ApplicationManager* manager;
	@property (strong, nonatomic) NSDate* date;
	@property NSUInteger category;
	@property NSUInteger alert;

	@property (weak, nonatomic) IBOutlet UIBarButtonItem* buttonSave;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldTitle;
	@property (weak, nonatomic) IBOutlet UILabel* labelDate;
	@property (weak, nonatomic) IBOutlet UILabel* labelTime;
	@property (weak, nonatomic) IBOutlet UILabel* labelAlert;
	@property (weak, nonatomic) IBOutlet UILabel* labelCategory;

	/**************************************/
	// PRIVATE MEMBER METHODS
	/**************************************/
	- (void) updateCategory;
	- (void) updateDateAndTime;
	- (void) enableSaveButton;
@end

@implementation AddNotificationViewController

/**************************************/
// PRIVATE MEMBER METHODS
/**************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
	// Hack with gesture recognizers to allow hiding the keyboard
	self.tableView.allowsSelection = NO;
	
	// Setup gesture recognizer
	UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
	tgr.delegate = self;
	[self.tableView addGestureRecognizer:tgr];
	
	// Get singleton instance
	self.manager = [ApplicationManager instance];
	
	// Populate initial values
	if (self.notificationToEdit) {
		
		// Update the title
		self.textFieldTitle.text = self.notificationToEdit.title;
		
		// Update default colors
		self.category = self.notificationToEdit.category;
		
		// Update alert
		self.alert = self.notificationToEdit.alert;
		
		// Set the dates
		self.date = self.notificationToEdit.start;
	}
	
	else {
		// Update default colors
		self.category = 0;
		
		// Update alert
		self.alert = 0;
		
		// Set the dates
		self.date = [NSDate dateWithTimeIntervalSinceNow:3600];
	}
	
	// Update UI
	[self updateCategory];
	[self updateAlert];
	[self updateDateAndTime];
	[self enableSaveButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Buttons
- (IBAction)onSave:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	
	if (self.completionHandler) {
		Notification* notification = [[Notification alloc] init];
		
		// If we're editing, preserve the ID
		if (self.notificationToEdit) {
			notification.uid = self.notificationToEdit.uid;
		}
		notification.start = self.date;
		notification.title = self.textFieldTitle.text;
		notification.category = self.category;
		notification.alert = self.alert;
		self.completionHandler (notification);
	}
	
	self.textFieldTitle.text = nil;
}

- (IBAction)onCancel:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	
	if (self.completionHandler) {
		self.completionHandler (nil);
	}
	
	self.textFieldTitle.text = nil;
}

- (IBAction)onDate:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	[self enableSaveButton];
}

- (IBAction)onCategory:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	[self enableSaveButton];
}

// Text Field
- (BOOL)textFieldShouldReturn:(UITextField*) textField {
	[self enableSaveButton];
	[self.textFieldTitle resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	[self enableSaveButton];
	return YES;
}

// Misc
- (void)enableSaveButton {
	self.buttonSave.enabled = self.textFieldTitle.text.length > 0 && ([self.date timeIntervalSince1970] >= [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]);
}

- (void)viewTapped:(UITapGestureRecognizer *)tgr {
	[self.textFieldTitle resignFirstResponder];
	[self enableSaveButton];
}

- (void) updateCategory {
	Category* category = [self.manager getCategoryAtIndex:self.category];
	self.labelCategory.text = category.name;
	self.labelCategory.textColor = category.color;
}

- (void) updateAlert {
	Alert* alert = [self.manager getAlertAtIndex:self.alert];
	self.labelAlert.text = alert.title;
}

- (void)updateDateAndTime {
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = NSDateFormatterMediumStyle;
	formatter.timeStyle = NSDateFormatterNoStyle;
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	self.labelDate.text = [formatter stringFromDate:self.date];
	
	formatter.dateStyle = NSDateFormatterNoStyle;
	formatter.timeStyle = NSDateFormatterShortStyle;
	
	self.labelTime.text = [formatter stringFromDate:self.date];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	
	if ([[segue identifier] isEqualToString:@"pickerPopoverSegue"]) {
		UIViewController* popoverViewController = (UIViewController*)segue.destinationViewController;
		popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
		popoverViewController.popoverPresentationController.delegate = self;
		
		TimePickerViewController* picker = segue.destinationViewController;
		picker.date = self.date;
		picker.completionHandler = ^(NSDate* date) {
			if (date != nil) {
				self.date = date;
				[self updateDateAndTime];
				[self enableSaveButton];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"categorySegue"]) {
		CategoryViewController* categoryView = (CategoryViewController*)segue.destinationViewController;
		categoryView.completionHandler = ^(NSInteger category) {
			if (category >= 0) {
				self.category = category;
				[self updateCategory];
				[self enableSaveButton];
			}
			
			[self.navigationController popViewControllerAnimated:YES];
			//[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"alertSegue"]) {
		AlertViewController* alertView = (AlertViewController*)segue.destinationViewController;
		alertView.completionHandler = ^(NSInteger alert) {
			if (alert >= 0) {
				self.alert = alert;
				[self updateAlert];
				[self enableSaveButton];
			}
			
			[self.navigationController popViewControllerAnimated:YES];
			//[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
}

#pragma mark - Delegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
	return UIModalPresentationNone;
}

@end
