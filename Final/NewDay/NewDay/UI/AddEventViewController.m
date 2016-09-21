//
//  AddEventViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/1/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "AddEventViewController.h"
#import "TimePickerViewController.h"
#import "CategoryViewController.h"
#import "AlertViewController.h"
#import "ApplicationManager.h"

@interface AddEventViewController ()
	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (strong, nonatomic) ApplicationManager* manager;
	@property (strong, nonatomic) NSDate* startDate;
	@property (strong, nonatomic) NSDate* endDate;
	@property NSUInteger category;
	@property NSUInteger alert;

	@property (weak, nonatomic) IBOutlet UIBarButtonItem* buttonSave;
	@property (weak, nonatomic) IBOutlet UITextField* textFieldTitle;
	@property (weak, nonatomic) IBOutlet UILabel* labelStartDate;
	@property (weak, nonatomic) IBOutlet UILabel* labelStartTime;
	@property (weak, nonatomic) IBOutlet UILabel* labelEndDate;
	@property (weak, nonatomic) IBOutlet UILabel* labelEndTime;
	@property (weak, nonatomic) IBOutlet UILabel* labelCategory;
	@property (weak, nonatomic) IBOutlet UILabel* labelAlert;
	/**************************************/
	// PRIVATE MEMBER METHODS
	/**************************************/
	- (void) updateCategory;
	- (void) updateAlert;
	- (void) updateDateAndTime;
	- (void) enableSaveButton;
@end

@implementation AddEventViewController

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
	if (self.eventToEdit) {
		
		// Update the title
		self.textFieldTitle.text = self.eventToEdit.title;
		
		// Update default colors
		self.category = self.eventToEdit.category;
		
		// Update alert
		self.alert = self.eventToEdit.alert;
		
		// Set the dates
		self.startDate = self.eventToEdit.start;
		self.endDate = self.eventToEdit.end;
	}
	
	else {
		// Update default colors
		self.category = 0;
		
		// Update alert
		self.alert = 0;
		
		// Set the dates
		self.startDate = [NSDate dateWithTimeIntervalSinceNow:0];
		self.endDate = [NSDate dateWithTimeIntervalSinceNow:3600];
	}
	
	// Update UI
	[self updateAlert];
	[self updateCategory];
	[self updateDateAndTime];
	[self enableSaveButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

// Buttons
- (IBAction)onStartDate:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	[self enableSaveButton];
}

- (IBAction)onEndDate:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	[self enableSaveButton];
}


- (IBAction)onButtonSave:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	
	if (self.completionHandler) {
		Event* event = [[Event alloc] init];
		
		// If we're editing, preserve the ID
		if (self.eventToEdit) {
			event.uid = self.eventToEdit.uid;
		}
		event.start = self.startDate;
		event.end = self.endDate;
		event.title = self.textFieldTitle.text;
		event.category = self.category;
		event.alert = self.alert;
		self.completionHandler (event);
	}
	
	self.textFieldTitle.text = nil;
}

- (IBAction)onButtonCancel:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	
	if (self.completionHandler) {
		self.completionHandler (nil);
	}
	
	self.textFieldTitle.text = nil;
}

// Misc
- (void)enableSaveButton {
	self.buttonSave.enabled = self.textFieldTitle.text.length > 0 && ([self.startDate timeIntervalSince1970] < [self.endDate timeIntervalSince1970]);
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
	
	_labelStartDate.text = [formatter stringFromDate:self.startDate];
	_labelEndDate.text = [formatter stringFromDate:self.endDate];
	
	formatter.dateStyle = NSDateFormatterNoStyle;
	formatter.timeStyle = NSDateFormatterShortStyle;
	
	_labelStartTime.text = [formatter stringFromDate:self.startDate];
	_labelEndTime.text = [formatter stringFromDate:self.endDate];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	if ([[segue identifier] isEqualToString:@"startPickerPopoverSegue"]) {
		UIViewController* popoverViewController = (UIViewController*)segue.destinationViewController;
		popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
		popoverViewController.popoverPresentationController.delegate = self;
		
		TimePickerViewController* picker = segue.destinationViewController;
		picker.date = _startDate;
		picker.completionHandler = ^(NSDate* date) {
			if (date != nil) {
				self.startDate = date;
				[self updateDateAndTime];
				[self enableSaveButton];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"endPickerPopoverSegue"]) {
		UIViewController* popoverViewController = (UIViewController*)segue.destinationViewController;
		popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
		popoverViewController.popoverPresentationController.delegate = self;
		
		TimePickerViewController* picker = segue.destinationViewController;
		picker.date = _endDate;
		picker.completionHandler = ^(NSDate* date) {
			if (date != nil) {
				self.endDate = date;
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
