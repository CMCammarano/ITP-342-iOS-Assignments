//
//  AddBlockViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "AddBlockViewController.h"
#import "TimePickerViewController.h"
#import "CategoryViewController.h"
#import "MultiSelectSegmentedControl.h"
#import "AlertViewController.h"
#import "ApplicationManager.h"

@interface AddBlockViewController ()
	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (strong, nonatomic) ApplicationManager* manager;
	@property (strong, nonatomic) NSDate* startTime;
	@property (strong, nonatomic) NSDate* endTime;
	@property NSUInteger category;
	@property NSUInteger alert;

	@property (weak, nonatomic) IBOutlet UITextField* textFieldTitle;
	@property (weak, nonatomic) IBOutlet UIBarButtonItem* buttonSave;
	@property (weak, nonatomic) IBOutlet UILabel* labelStartTime;
	@property (weak, nonatomic) IBOutlet UILabel* labelEndTime;
	@property (weak, nonatomic) IBOutlet UILabel* labelAlert;
	@property (weak, nonatomic) IBOutlet UILabel* labelCategory;
	@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl* dateSegmentedControl;

	/**************************************/
	// PRIVATE MEMBER METHODS
	/**************************************/
	- (void) updateCategory;
	- (void) updateDateAndTime;
	- (void) enableSaveButton;
@end

@implementation AddBlockViewController

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
	if (self.blockToEdit) {
		
		// Update the title
		self.textFieldTitle.text = self.blockToEdit.title;
		
		// Update default colors
		self.category = self.blockToEdit.category;
		
		// Update alert
		self.alert = self.blockToEdit.alert;
		
		// Set the dates
		self.startTime = self.blockToEdit.start;
		self.endTime = self.blockToEdit.end;
		
		// Set the days
		NSIndexSet* set = [[NSIndexSet alloc] initWithIndexSet:self.blockToEdit.days];
		self.dateSegmentedControl.selectedSegmentIndexes = set;
	}
	
	else {
		// Update default colors
		self.category = 0;
		
		// Update alert
		self.alert = 0;
		
		// Set the dates
		self.startTime = [NSDate dateWithTimeIntervalSinceNow:0];
		self.endTime = [NSDate dateWithTimeIntervalSinceNow:3600];
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
	
	// TODO: Add all block features
	if (self.completionHandler) {
		Block* block = [[Block alloc] init];
		
		// If we're editing, preserve the ID
		if (self.blockToEdit) {
			block.uid = self.blockToEdit.uid;
		}
		block.start = self.startTime;
		block.end = self.endTime;
		block.title = self.textFieldTitle.text;
		block.category = self.category;
		block.alert = self.alert;
		block.days = [[NSMutableIndexSet alloc] initWithIndexSet:self.dateSegmentedControl.selectedSegmentIndexes];
		self.completionHandler (block);
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

- (IBAction)onStartTime:(id)sender {
	[self.textFieldTitle resignFirstResponder];
	[self enableSaveButton];
}

- (IBAction)onEndTime:(id)sender {
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

// Segmented control
- (IBAction)segmentedControlChanged:(id)sender {
	[self enableSaveButton];
	[self.textFieldTitle resignFirstResponder];
}

// Misc
- (void)enableSaveButton {
	self.buttonSave.enabled = self.textFieldTitle.text.length > 0 && ([self.startTime timeIntervalSince1970] < [self.endTime timeIntervalSince1970]) && self.dateSegmentedControl.selectedSegmentTitles.count > 0;
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
	formatter.dateStyle = NSDateFormatterNoStyle;
	formatter.timeStyle = NSDateFormatterShortStyle;
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	self.labelStartTime.text = [formatter stringFromDate:self.startTime];
	self.labelEndTime.text = [formatter stringFromDate:self.endTime];
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
		picker.date = self.startTime;
		picker.completionHandler = ^(NSDate* date) {
			if (date != nil) {
				self.startTime = date;
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
		picker.date = self.endTime;
		picker.completionHandler = ^(NSDate* date) {
			if (date != nil) {
				self.endTime = date;
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
