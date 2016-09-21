//
//  ViewController.m
//  Lab3
//
//  Created by Colin Cammarano on 2/10/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
	@property (nonatomic) float billValue;
	@property (nonatomic) float taxPercentValue;
	@property (nonatomic) float taxValue;
	@property (nonatomic) float totalNoTipValue;
	@property (nonatomic) float tipPercentValue;
	@property (nonatomic) float tipValue;
	@property (nonatomic) float totalValue;
	@property (nonatomic) float totalSplitValue;
	@property (nonatomic) int splitValue;
	@property (nonatomic) BOOL useTax;

	@property (weak, nonatomic) IBOutlet UITextField* textFieldBill;
	@property (weak, nonatomic) IBOutlet UISegmentedControl* selectFieldTaxRate;
	@property (weak, nonatomic) IBOutlet UILabel* labelTaxValue;
	@property (weak, nonatomic) IBOutlet UISwitch* switchTax;
	@property (weak, nonatomic) IBOutlet UILabel* labelTotalNoTip;
	@property (weak, nonatomic) IBOutlet UILabel* labelTipPercent;
	@property (weak, nonatomic) IBOutlet UISlider* sliderTipPercent;
	@property (weak, nonatomic) IBOutlet UILabel* labelSplitValue;
	@property (weak, nonatomic) IBOutlet UIStepper* stepperSplitValue;
	@property (weak, nonatomic) IBOutlet UILabel* labelTipValue;
	@property (weak, nonatomic) IBOutlet UILabel* labelTotalValue;
	@property (weak, nonatomic) IBOutlet UILabel* labelTotalSplitValue;
	@property (weak, nonatomic) IBOutlet UIButton* buttonClear;
	@property (weak, nonatomic) IBOutlet UIButton* buttonBackground;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[self clear];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)defaults {
	// Numerical properities
	self.splitValue = 1;
	self.billValue = 0;
	self.taxPercentValue = 7.5f;
	self.taxValue = 0;
	self.totalNoTipValue = 0;
	self.tipPercentValue = 15;
	self.tipValue = 0;
	self.totalValue = 0;
	self.totalSplitValue = 0;
	self.useTax = true;
}

// Resets the data
- (void)clear {
	
	[self defaults];
	
	// Top view
	self.textFieldBill.text = @"";
	self.selectFieldTaxRate.selectedSegmentIndex = 0;
	self.labelTaxValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.taxValue];
	self.labelTotalNoTip.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.totalNoTipValue];
	
	// Middle view
	self.switchTax.on = self.useTax;
	self.sliderTipPercent.value = self.tipPercentValue;
	self.labelTipPercent.text = [NSString stringWithFormat:@"%d%@", (int)self.sliderTipPercent.value, @"%"];
	self.stepperSplitValue.value = self.splitValue;
	self.labelSplitValue.text = [NSString stringWithFormat:@"%d", (int)self.stepperSplitValue.value];
	
	// Bottom view
	self.labelTipValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.tipValue];
	self.labelTotalValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.totalValue];
	self.labelTotalSplitValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.totalSplitValue];
}

// Updates all of the labels
- (void)update {
	
	// Get values from UI elements
	if (self.textFieldBill.text && self.textFieldBill.text.length > 0) {
		self.billValue = [self.textFieldBill.text floatValue];
	}
	
	else {
		self.billValue = 0;
	}
	
	self.taxPercentValue = [[self.selectFieldTaxRate titleForSegmentAtIndex:self.selectFieldTaxRate.selectedSegmentIndex] floatValue];
	self.useTax = self.switchTax.on;
	self.tipPercentValue = self.sliderTipPercent.value;
	self.splitValue = (int)self.stepperSplitValue.value;
	
	// Calculate numeric values
	self.taxValue = 0.01f * self.billValue * self.taxPercentValue;
	self.totalNoTipValue = (self.useTax) ? (self.billValue + self.taxValue) : (self.billValue);
	self.tipValue = self.totalNoTipValue * (int)self.tipPercentValue * 0.01f;
	self.totalValue = (self.useTax) ? (self.totalNoTipValue + self.tipValue) : (self.totalNoTipValue + self.taxValue + self.tipValue);
	self.totalSplitValue = self.totalValue / (float)self.splitValue;
	
	// Top view
	self.labelTaxValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.taxValue];
	self.labelTotalNoTip.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.totalNoTipValue];
	
	// Middle view
	self.switchTax.on = self.useTax;
	self.sliderTipPercent.value = self.tipPercentValue;
	self.labelTipPercent.text = [NSString stringWithFormat:@"%d%@", (int)self.sliderTipPercent.value, @"%"];
	self.stepperSplitValue.value = self.splitValue;
	self.labelSplitValue.text = [NSString stringWithFormat:@"%d", (int)self.stepperSplitValue.value];
	
	// Bottom view
	self.labelTipValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.tipValue];
	self.labelTotalValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.totalValue];
	self.labelTotalSplitValue.text = [NSString stringWithFormat:@"%@%.02f", @"$", self.totalSplitValue];
}

// Lower the keyboard
- (IBAction)actionBackgroundClicked:(id)sender {
	[self.textFieldBill resignFirstResponder];
	[self update];
}

// Update when any field is modified
- (IBAction)actionTaxRateChanged:(id)sender {
	[self update];
}

- (IBAction)actionUseTaxToggled:(id)sender {
	[self update];
}

- (IBAction)actionTipPercentChanged:(id)sender {
	[self update];
}

- (IBAction)actionSplitAmountChanged:(id)sender {
	[self update];
}

// Reset the application
- (IBAction)actionButtonClearClicked:(id)sender {
	
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Clear fields?" message:@"All fields will be cleared and all data will be lost." preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle :@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction* action) {}];
	UIAlertAction* clearAction = [UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) { [self clear]; }];
	[alertController addAction:cancelAction];
	[alertController addAction:clearAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
