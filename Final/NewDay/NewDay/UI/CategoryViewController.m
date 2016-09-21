//
//  CategoryViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/3/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "CategoryViewController.h"
#import "ApplicationManager.h"

@interface CategoryViewController ()

	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (strong, nonatomic) ApplicationManager* manager;
@end

@implementation CategoryViewController

/**************************************/
// PRIVATE MEMBER VARIABLES
/**************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Set up singleton
	self.manager = [ApplicationManager instance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCancel:(id)sender {
	if (self.completionHandler) {
		self.completionHandler (-1);
	}
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.manager numberOfCategories];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	const NSString* kReuseIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString*)kReuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	Category* category = [self.manager getCategoryAtIndex:indexPath.row];
	cell.textLabel.text = @"\u2022";
	cell.textLabel.font = [UIFont systemFontOfSize:24];
	cell.textLabel.textColor = category.color;
	
	cell.detailTextLabel.text = category.name;
	cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.completionHandler) {
		self.completionHandler (indexPath.row);
	}
}

@end
