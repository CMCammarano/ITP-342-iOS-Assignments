//
//  UpcomingViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/1/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "UpcomingViewController.h"
#import "AddEventViewController.h"
#import "AddBlockViewController.h"
#import "AddNotificationViewController.h"
#import "LoginViewController.h"
#import "UpcomingDetailViewController.h"
#import "ApplicationManager.h"

@interface UpcomingViewController ()
	/**************************************/
	// PRIVATE PROPERTIES
	/**************************************/
	@property (weak, nonatomic) IBOutlet UIBarButtonItem* buttonLogin;
	@property (strong, nonatomic) Upcoming* upcoming;
	@property (strong, nonatomic) ApplicationManager* manager;

	/**************************************/
	// PRIVATE MEMBER METHODS
	/**************************************/
	- (void) setLoginButtonBehavior;

@end

@implementation UpcomingViewController

/**************************************/
// PRIVATE MEMBER METHODS
/**************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
	// Do any additional setup after loading the view, typically from a nib.
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	// Get singleton instance
	self.manager = [ApplicationManager instance];
	[self.manager loadUser:^{
		[self.tableView reloadData];
	}];
	
	// Update UI
	[self setLoginButtonBehavior];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAddButton:(id)sender {
	UIAlertController* alertController = [UIAlertController
										alertControllerWithTitle:@"Add Entry"
										message:@"Add an entry to the calendar!"
										preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction* cancelAction = [UIAlertAction
								   		actionWithTitle:@"Cancel"
										style:UIAlertActionStyleCancel
										handler:^(UIAlertAction* action) { /* code */ }];
	
	UIAlertAction* blockAction = [UIAlertAction
								  		actionWithTitle :@"Add Block"
										style: UIAlertActionStyleDefault
										handler:^(UIAlertAction* action) {
											[self performSegueWithIdentifier:@"addBlockSegue" sender:self];
										}];
	
	UIAlertAction* eventAction = [UIAlertAction
								  		actionWithTitle :@"Add Event"
										style: UIAlertActionStyleDefault
										handler:^(UIAlertAction* action) {
											[self performSegueWithIdentifier:@"addEventSegue" sender:self];
										}];
	
	UIAlertAction* notifAction = [UIAlertAction
								  		actionWithTitle :@"Add Notification"
										style: UIAlertActionStyleDefault
										handler:^(UIAlertAction* action) {
											[self performSegueWithIdentifier:@"addNotificationSegue" sender:self];
										}];
	
	[alertController addAction:cancelAction];
	[alertController addAction:blockAction];
	[alertController addAction:eventAction];
	[alertController addAction:notifAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)buttonLogin:(id)sender {
	if (!self.manager.currentUser) {
		[self performSegueWithIdentifier:@"loginSegue" sender:self];
		[self setLoginButtonBehavior];
	}
	
	else {
		[self.manager logoff];
		[self setLoginButtonBehavior];
		[self.tableView reloadData];
	}
}

#pragma mark - Selecting Upcoming
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.upcoming = [self.manager getUpcomingEventAtIndex:indexPath.row];
	[self performSegueWithIdentifier:@"showUpcomingDetailSegue" sender:self];
}

#pragma mark - UI Updates
- (void) setLoginButtonBehavior {
	User* user = self.manager.currentUser;
	if (user) {
		//self.navigationItem.leftBarButtonItem.enabled = false;
		self.buttonLogin.title = @"Logoff";
		self.navigationItem.title = user.username;
		self.navigationItem.rightBarButtonItem.enabled = true;
	}
	
	else {
		self.buttonLogin.title = @"Login";
		self.navigationItem.title = @"Upcoming";
		self.navigationItem.rightBarButtonItem.enabled = false;
	}
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.manager numberOfUpcomingEvents];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 	const NSString* reuseIdentifier = @"UpcomingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString*)reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	Upcoming* upcoming = [self.manager getUpcomingEventAtIndex:indexPath.row];
	cell.textLabel.text = [upcoming title];
	
	// Get the category
	Category* category = [self.manager getCategoryAtIndex:upcoming.entry.category];
	cell.textLabel.textColor = category.color;
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = NSDateFormatterMediumStyle;
	formatter.timeStyle = NSDateFormatterNoStyle;
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	cell.detailTextLabel.text = [formatter stringFromDate:[upcoming date]];
	
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.manager removeUpcomingEventAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
	
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	if ([[segue identifier] isEqualToString:@"addEventSegue"]) {
		AddEventViewController* addEvent = segue.destinationViewController.childViewControllers.firstObject;
		addEvent.eventToEdit = nil;
		addEvent.completionHandler = ^(Event* event) {
			if (event != nil) {
				[self.manager addEvent:event];
				[self.tableView reloadData];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"addBlockSegue"]) {
		AddBlockViewController* add = segue.destinationViewController.childViewControllers.firstObject;
		add.blockToEdit = nil;
		add.completionHandler = ^(Block* block) {
			if (block != nil) {
				[self.manager addBlock:block];
				[self.tableView reloadData];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"addNotificationSegue"]) {
		AddNotificationViewController* add = segue.destinationViewController.childViewControllers.firstObject;
		add.notificationToEdit = nil;
		add.completionHandler = ^(Notification* notification) {
			if (notification != nil) {
				[self.manager addNotification:notification];
				[self.tableView reloadData];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"loginSegue"]) {
		LoginViewController* login = segue.destinationViewController.childViewControllers.firstObject;
		login.completionHandler = ^() {
			[self dismissViewControllerAnimated:YES completion:nil];
			[self setLoginButtonBehavior];
			[self.tableView reloadData];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"showUpcomingDetailSegue"]) {
		UpcomingDetailViewController* detail = segue.destinationViewController;
		detail.upcoming = self.upcoming;
		detail.uView = self;
	}
}

@end
