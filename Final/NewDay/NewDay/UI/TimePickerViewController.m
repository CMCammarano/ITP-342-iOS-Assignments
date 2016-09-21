//
//  TimePickerViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/1/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "TimePickerViewController.h"

@interface TimePickerViewController ()
	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (weak, nonatomic) IBOutlet UIDatePicker* datePicker;
@end

@implementation TimePickerViewController

/**************************************/
// PRIVATE MEMBER METHODS
/**************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	_datePicker.transform = CGAffineTransformMakeScale(0.9, 0.9);
	_datePicker.date = _date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDonePressed:(id)sender {
	
	// Get the date, then return it
	_date = _datePicker.date;
	if (self.completionHandler) {
		self.completionHandler (self.date);
	}
}

@end
