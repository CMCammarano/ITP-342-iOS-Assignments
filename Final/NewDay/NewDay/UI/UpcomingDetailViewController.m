//
//  UpcomingDetailViewController.m
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "UpcomingDetailViewController.h"
#import "AddEventViewController.h"
#import "AddBlockViewController.h"
#import "AddNotificationViewController.h"

@interface UpcomingDetailViewController ()
	@property (weak, nonatomic) IBOutlet UILabel* labelTitle;
	@property (weak, nonatomic) IBOutlet UILabel* labelDate;
	@property (weak, nonatomic) IBOutlet UILabel* labelTime;
	@property (weak, nonatomic) IBOutlet UILabel* labelCategory;
	@property (weak, nonatomic) IBOutlet UILabel* labelAlert;
	@property (weak, nonatomic) IBOutlet UILabel* labelQuote;
	@property (weak, nonatomic) IBOutlet UILabel* labelAuthor;

	@property (strong, nonatomic) ApplicationManager* manager;
@end

@implementation UpcomingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Get the manager
	self.manager = [ApplicationManager instance];
	
    // Do any additional setup after loading the view.
	[self updateUI];
	[self updateQuote];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Buttons
- (IBAction)onEdit:(id)sender {
	
	if (self.upcoming.entry.class == [Block class]) {
		[self performSegueWithIdentifier:@"editBlockSegue" sender:self];
	}
	
	if (self.upcoming.entry.class == [Notification class]) {
		[self performSegueWithIdentifier:@"editNotificationSegue" sender:self];
	}
	
	if (self.upcoming.entry.class == [Event class]) {
		[self performSegueWithIdentifier:@"editEventSegue" sender:self];
	}
}

// UI
- (void) updateUI {
	if (self.upcoming) {
		self.labelTitle.text = self.upcoming.title;
		
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = NSDateFormatterLongStyle;
		formatter.timeStyle = NSDateFormatterNoStyle;
		formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		self.labelDate.text = [formatter stringFromDate:[self.upcoming date]];
		
		formatter.dateStyle = NSDateFormatterNoStyle;
		formatter.timeStyle = NSDateFormatterShortStyle;
		self.labelTime.text = [NSString stringWithFormat:@"Starts at %@", [formatter stringFromDate:[self.upcoming date]]];
		
		Category* category = [self.manager getCategoryAtIndex:self.upcoming.entry.category];
		self.labelCategory.text = category.name;
		self.labelCategory.textColor = category.color;
		
		Alert* alert = [self.manager getAlertAtIndex:self.upcoming.entry.alert];
		self.labelAlert.text = alert.title;
	}
}

- (void) updateQuote {
	Quote* quote = [self.manager randomQuote];
	self.labelQuote.text = [NSString stringWithFormat:@"\"%@\"", quote.quote];
	self.labelAuthor.text = [NSString stringWithFormat:@"- %@", quote.author];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	if ([[segue identifier] isEqualToString:@"editEventSegue"]) {
		AddEventViewController* addEvent = segue.destinationViewController.childViewControllers.firstObject;
		addEvent.eventToEdit = (Event*)self.upcoming.entry;
		addEvent.completionHandler = ^(Event* event) {
			if (event != nil) {
				[self.manager editEvent:event];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
			[self updateUI];
			[self.uView.tableView reloadData];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"editBlockSegue"]) {
		AddBlockViewController* add = segue.destinationViewController.childViewControllers.firstObject;
		add.blockToEdit = (Block*)self.upcoming.entry;
		add.completionHandler = ^(Block* block) {
			if (block != nil) {
				[self.manager editBlock:block];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
			[self updateUI];
			[self.uView.tableView reloadData];
		};
	}
	
	if ([[segue identifier] isEqualToString:@"editNotificationSegue"]) {
		AddNotificationViewController* add = segue.destinationViewController.childViewControllers.firstObject;
		add.notificationToEdit = (Notification*)self.upcoming.entry;
		add.completionHandler = ^(Notification* notification) {
			if (notification != nil) {
				[self.manager editNotification:notification];
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
			[self updateUI];
			[self.uView.tableView reloadData];
		};
	}
}

@end
