//
//  ViewController.m
//  Lab2
//
//  Created by Colin Cammarano on 1/27/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// Did it the first way! :D
- (IBAction)backgroundTouched:(id)sender {
	[self.userNameField resignFirstResponder];
}

- (IBAction)userNameFieldDone:(id)sender {
	[sender resignFirstResponder];
}

- (IBAction)buttonNvidiaTouched:(id)sender {
	
	NSString* textToDisplay;
	if (self.userNameField.text && self.userNameField.text.length > 0) {
		textToDisplay = [NSString stringWithFormat:@"Yes, %@, yes! Team Green is where it's at!", self.userNameField.text];
	}
	
	else {
		textToDisplay = @"Yes! Team Green is where it's at!";
	}
	
	self.userMessage.text = textToDisplay;
}

- (IBAction)buttonAmdTouched:(id)sender {
	
	NSString* textToDisplay;
	if (self.userNameField.text && self.userNameField.text.length > 0) {
		textToDisplay = [NSString stringWithFormat:@"Ah, I see where you stand, %@. While I prefer NVidia, AMD makes some pretty great cards for the price. Team Red all the way!", self.userNameField.text];
	}
	
	else {
		textToDisplay = @"Ah, I see. While I prefer NVidia, AMD makes some pretty great cards for the price. Team Red all the way!";
	}
	self.userMessage.text = textToDisplay;
}

@end
