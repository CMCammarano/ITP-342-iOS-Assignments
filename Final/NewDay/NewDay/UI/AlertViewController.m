//
//  AlertViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/5/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "AlertViewController.h"
#import "ApplicationManager.h"

@interface AlertViewController ()

	@property (strong, nonatomic) ApplicationManager* manager;
@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Get the singleton
	self.manager = [ApplicationManager instance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.manager numberOfAlerts];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.completionHandler) {
		self.completionHandler (indexPath.row);
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertCell" forIndexPath:indexPath];
    
    // Configure the cell...
	Alert* alert = [self.manager getAlertAtIndex:indexPath.row];
	cell.textLabel.text = alert.title;
    
    return cell;
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
