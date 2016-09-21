//
//  NavigationViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 4/29/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "NavigationViewController.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

/**************************************/
// PRIVATE MEMBER METHODS
/**************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.navigationBar.barTintColor = [UIColor colorWithRed:0.0f green:0.737f blue:0.831f alpha:1.0f];
	self.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationBar.translucent = YES;
	[self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
