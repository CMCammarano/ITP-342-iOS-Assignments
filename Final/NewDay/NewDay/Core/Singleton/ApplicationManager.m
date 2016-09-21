//
//  ApplicationManager.m
//  NewDay
//
//  Created by Colin Cammarano on 4/28/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "ApplicationManager.h"
#import "Cryptography.h"

@interface ApplicationManager ()

/**************************************/
// PRIVATE PROPERTIES
/**************************************/
@property (strong, nonatomic) NSMutableArray* quotes;
@property (strong, nonatomic) NSMutableArray* categories;
@property (strong, nonatomic) NSMutableArray* alerts;
@property (strong, nonatomic) NSMutableArray* upcoming;
@property (strong, nonatomic) NSMutableArray* blocks;
@property (strong, nonatomic) NSMutableArray* events;
@property (strong, nonatomic) NSMutableArray* notifications;
@property (strong, nonatomic) NSString* currentUserFilepath;

// Firebase reference
@property (strong, nonatomic) Firebase* database;

// Calendar database
@property (strong, nonatomic) EKCalendar* calendar;
@property (strong, nonatomic) EKCalendar* reminders;
@property (strong, nonatomic) EKEventStore* eventStore;
@property (nonatomic) BOOL isAccessToEventStoreGranted;

/**************************************/
// PRIVATE MEMBER FUNCTIONS
/**************************************/
- (void) loadCategories;
- (void) loadQuotes;
- (void) loadAlerts;
- (void) setupArrays;
- (void) setupFirebase;
- (void) addUpcoming: (Entry*) entry;
- (void) addCalendarEvent: (Event*) event;
- (void) addReminderNotification: (Notification*) notification;
- (void) saveUser;
- (void) removeUser;
- (NSData*) hashPassword: (NSString*) password;
- (NSString*) restorePassword: (NSData*) hashedPassword;
@end

@implementation ApplicationManager

/**************************************/
// CONSTANTS
/**************************************/
const NSString* kBlockDataFile = @"Blocks.plist";
const NSString* kEventDataFile = @"Events.plist";
const NSString* kNotificationDataFile = @"Notifications.plist";
const NSString* kCurrentUserFile = @"CurrentUser.plist";
const NSString* kEncryptionPassword = @"new-day-hashing-string";
const NSString* kFirebaseURL = @"https://newday-demo.firebaseio.com/";

/**************************************/
// PUBLIC MEMBER FUNCTIONS
/**************************************/
// Creation
+ (instancetype) instance {
	static ApplicationManager* singleton;
	if (!singleton) {
		singleton = [[self alloc] init];
	}
	
	return singleton;
}

- (instancetype) init {
	if (self = [super init]) {
		
		// Setup the database
		[self setupFirebase];
		
		// Load up the calendar and event database
		[self setupEvents];
		
		// Load local data, load the user (if they exist) and then synchronize with the database
		[self setupArrays];
		[self loadCategories];
		[self loadQuotes];
		[self loadAlerts];
		//[self loadUser];
	}
	return self;
}

// Upcoming events
- (NSUInteger) numberOfUpcomingEvents {
	return self.upcoming.count;
}

- (Upcoming*) getUpcomingEventAtIndex: (NSUInteger) index {
	if (index < self.upcoming.count) {
		return [self.upcoming objectAtIndex:index];
	}
	
	return nil;
}

- (void) removeUpcomingEventAtIndex: (NSUInteger) index {
	
	if (index < self.upcoming.count) {
		
		// Remove the entry associated with the upcoming event
		Upcoming* upcoming = [self.upcoming objectAtIndex:index];
		if (upcoming.entry.class == [Block class]) {
			[self.blocks removeObject:upcoming.entry];
			
			// Remove the entry from the database!
			if (self.currentUser) {
				Firebase* blockRef = [[[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"blocks"] childByAppendingPath:upcoming.entry.uid];
				[blockRef removeValue];
			}
		}
			 
		if (upcoming.entry.class == [Notification class]) {
			[self removeReminderNotification:(Notification*)upcoming.entry];
			[self.notifications removeObject:upcoming.entry];
			
			// Remove the entry from the database!
			if (self.currentUser) {
				Firebase* notificationRef = [[[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"notifications"] childByAppendingPath:upcoming.entry.uid];
				[notificationRef removeValue];
			}
		}
				  
		if (upcoming.entry.class == [Event class]) {
			[self removeCalendarEvent:(Event*)upcoming.entry];
			[self.events removeObject:upcoming.entry];
			
			// Remove the entry from the database!
			if (self.currentUser) {
				Firebase* eventRef = [[[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"events"] childByAppendingPath:upcoming.entry.uid];
				[eventRef removeValue];
			}
		}
		
		// Remove the upcoming event
		[self.upcoming removeObjectAtIndex:index];
	}
}

// Categories
- (NSUInteger) numberOfCategories {
	return self.categories.count;
}

- (Category*) getCategoryAtIndex: (NSUInteger) index {
	if (index < self.categories.count) {
		return [self.categories objectAtIndex:index];
	}
	
	return nil;
}

// Alerts
- (NSUInteger) numberOfAlerts {
	return self.alerts.count;
}

- (Alert*) getAlertAtIndex: (NSUInteger) index {
	if (index < self.alerts.count) {
		return [self.alerts objectAtIndex:index];
	}
	
	return nil;
}

// Quotes
- (Quote*) randomQuote {
	NSUInteger index = (NSUInteger)arc4random_uniform((int)self.quotes.count);
	return [self.quotes objectAtIndex:index];
}

// Logging in and registering users
- (void) logoff {
	[self.database unauth];
	[self removeUser];
	[self setupArrays];
}

- (void) loginUser: (NSString*) email withPassword: (NSString*) password withBlock:(LoginCompletionBlock)block {
	[self.database authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
		if (error) {
			// There was an error logging into the account
		}
		
		else {
			
			// Get the user entry out of the database foo!
			NSString* uid = authData.uid;
		
			[self.database observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
				FDataSnapshot* users = [snapshot childSnapshotForPath:@"users"];
				NSDictionary* user = [users childSnapshotForPath:uid].value;
				self.currentUser = [[User alloc] init];
				self.currentUser.uid = uid;
				self.currentUser.name = [user valueForKey:@"name"];
				self.currentUser.email = [user valueForKey:@"email"];
				self.currentUser.username = [user valueForKey:@"username"];
				self.currentUser.password = [self hashPassword:password];
				
				// Save current user to the plist -- we want users to be persistently stored so logins can persist throughout app runs
				[self saveUser];
				
				// Now, get entries in the database
				FDataSnapshot* userRef = [[snapshot childSnapshotForPath:@"users"] childSnapshotForPath:uid];
				self.currentUser.uid = uid;
				
				// Once the user is loaded, we can attempt to get their data from the database! Start with blocks
				FDataSnapshot* blockRef = [userRef childSnapshotForPath:@"blocks"];
				for (FDataSnapshot* b in [blockRef children]) {
					
					// Create the block
					Block* block = [[Block alloc] init];
					block.title = [b childSnapshotForPath:@"title"].value;
					block.category = [[b childSnapshotForPath:@"category"].value unsignedIntegerValue];
					block.alert = [[b childSnapshotForPath:@"alert"].value unsignedIntegerValue];
					
					// Reconstruct the dates
					NSCalendar* calendar = [NSCalendar currentCalendar];
					
					// Start date
					NSDictionary* start = [b childSnapshotForPath:@"start"].value;
					NSDateComponents* startComponents = [[NSDateComponents alloc] init];
					[startComponents setDay:[(NSNumber*)[start objectForKey:@"day"] integerValue]];
					[startComponents setMonth:[(NSNumber*)[start objectForKey:@"month"] integerValue]];
					[startComponents setYear:[(NSNumber*)[start objectForKey:@"year"] integerValue]];
					[startComponents setHour:[(NSNumber*)[start objectForKey:@"hour"] integerValue]];
					[startComponents setMinute:[(NSNumber*)[start objectForKey:@"minute"] integerValue]];
					block.start = [calendar dateFromComponents:startComponents];
					
					// Start date
					NSDictionary* end = [b childSnapshotForPath:@"end"].value;
					NSDateComponents* endComponents = [[NSDateComponents alloc] init];
					[endComponents setDay:[(NSNumber*)[end objectForKey:@"day"] integerValue]];
					[endComponents setMonth:[(NSNumber*)[end objectForKey:@"month"] integerValue]];
					[endComponents setYear:[(NSNumber*)[end objectForKey:@"year"] integerValue]];
					[endComponents setHour:[(NSNumber*)[end objectForKey:@"hour"] integerValue]];
					[endComponents setMinute:[(NSNumber*)[end objectForKey:@"minute"] integerValue]];
					block.end = [calendar dateFromComponents:endComponents];
					
					// Days
					NSArray* days = [b childSnapshotForPath:@"days"].value;
					NSMutableIndexSet* set = [[NSMutableIndexSet alloc] init];
					for (NSNumber* i in days) {
						[set addIndex:[i unsignedIntegerValue]];
					}
					block.days = set;
					
					// Set the ID of the entry
					block.uid = b.key;
					
					// Add the block locally
					[self.blocks addObject:block];
					
					// TODO: Add upcoming events for the blocks in each week.
					[self addUpcoming:block];
				}
				
				// Now, let's do events!
				FDataSnapshot* eventRef = [userRef childSnapshotForPath:@"events"];
				for (FDataSnapshot* b in [eventRef children]) {
					
					// Create the block
					Event* event = [[Event alloc] init];
					event.title = [b childSnapshotForPath:@"title"].value;
					event.category = [[b childSnapshotForPath:@"category"].value unsignedIntegerValue];
					event.alert = [[b childSnapshotForPath:@"alert"].value unsignedIntegerValue];
					
					// Reconstruct the dates
					NSCalendar* calendar = [NSCalendar currentCalendar];
					
					// Start date
					NSDictionary* start = [b childSnapshotForPath:@"start"].value;
					NSDateComponents* startComponents = [[NSDateComponents alloc] init];
					[startComponents setDay:[(NSNumber*)[start objectForKey:@"day"] integerValue]];
					[startComponents setMonth:[(NSNumber*)[start objectForKey:@"month"] integerValue]];
					[startComponents setYear:[(NSNumber*)[start objectForKey:@"year"] integerValue]];
					[startComponents setHour:[(NSNumber*)[start objectForKey:@"hour"] integerValue]];
					[startComponents setMinute:[(NSNumber*)[start objectForKey:@"minute"] integerValue]];
					event.start = [calendar dateFromComponents:startComponents];
					
					// Start date
					NSDictionary* end = [b childSnapshotForPath:@"end"].value;
					NSDateComponents* endComponents = [[NSDateComponents alloc] init];
					[endComponents setDay:[(NSNumber*)[end objectForKey:@"day"] integerValue]];
					[endComponents setMonth:[(NSNumber*)[end objectForKey:@"month"] integerValue]];
					[endComponents setYear:[(NSNumber*)[end objectForKey:@"year"] integerValue]];
					[endComponents setHour:[(NSNumber*)[end objectForKey:@"hour"] integerValue]];
					[endComponents setMinute:[(NSNumber*)[end objectForKey:@"minute"] integerValue]];
					event.end = [calendar dateFromComponents:endComponents];
					
					// Set the ID of the entry
					event.uid = b.key;
					
					// Add the block locally
					[self.events addObject:event];
					
					// Add the upcoming entry
					[self addUpcoming:event];
				}
				
				// We'll do notifications last!
				FDataSnapshot* notificationRef = [userRef childSnapshotForPath:@"notifications"];
				for (FDataSnapshot* b in [notificationRef children]) {
					
					// Create the block
					Notification* notification = [[Notification alloc] init];
					notification.title = [b childSnapshotForPath:@"title"].value;
					notification.category = [[b childSnapshotForPath:@"category"].value unsignedIntegerValue];
					notification.alert = [[b childSnapshotForPath:@"alert"].value unsignedIntegerValue];
					
					// Reconstruct the dates
					NSCalendar* calendar = [NSCalendar currentCalendar];
					
					// Start date
					NSDictionary* start = [b childSnapshotForPath:@"start"].value;
					NSDateComponents* startComponents = [[NSDateComponents alloc] init];
					[startComponents setDay:[(NSNumber*)[start objectForKey:@"day"] integerValue]];
					[startComponents setMonth:[(NSNumber*)[start objectForKey:@"month"] integerValue]];
					[startComponents setYear:[(NSNumber*)[start objectForKey:@"year"] integerValue]];
					[startComponents setHour:[(NSNumber*)[start objectForKey:@"hour"] integerValue]];
					[startComponents setMinute:[(NSNumber*)[start objectForKey:@"minute"] integerValue]];
					notification.start = [calendar dateFromComponents:startComponents];
					
					// Set the ID of the entry
					notification.uid = b.key;
					
					// Add the block locally
					[self.notifications addObject:notification];
					
					// Add the upcoming entry
					[self addUpcoming:notification];
				}
				
				// Fire the completion handler here
				if (block) {
					block ();
				}
			}];
		}
	}];
}

- (void) registerUser: (NSString*) name withUsername: (NSString*) username withEmail: (NSString*) email withPassword: (NSString*) password withBlock: (RegisterCompletionBlock) block {
	
	// Create a new user -- this will also log in the new user
	[self.database createUser:email password:password withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
		if (error) {
			// There was an error creating the account
	 	}
		
		else {
			NSString* uid = [result objectForKey:@"uid"];
			Firebase* users = [self.database childByAppendingPath:@"users"];
			
			// Create user entry in the database
			NSDictionary* userData = @{
				@"name": name,
				@"username": username,
				@"email": email
			};
			
			// Save the data to the database
			[[users childByAppendingPath:uid] setValue:userData];
			
			// Set the current user
			self.currentUser = [[User alloc] init];
			self.currentUser.uid = uid;
			self.currentUser.name = name;
			self.currentUser.username = username;
			self.currentUser.email = email;
			self.currentUser.password = [self hashPassword:password];
			
			// Save the current user
			[self saveUser];
			
			// Fire the completion handler here
			if (block) {
				block ();
			}
		}
	}];
}

// Add entries to the calendar and the upcoming list
- (void) addBlock: (Block*) block {
	
	// Add the block to the database
	if (self.currentUser) {
		Firebase* blocks = [[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"blocks"];
		Firebase* ref = [blocks childByAutoId];
		
		// Needed to separate out calendar components
		NSCalendar* calendar = [NSCalendar currentCalendar];
		NSDateComponents* startComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:block.start];
		NSDateComponents* endComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:block.end];
		
		NSMutableArray* days = [NSMutableArray arrayWithCapacity:0];
		[block.days enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
			[days addObject:[NSNumber numberWithUnsignedInteger:idx]];
		}];
		
		NSDictionary* blockData = @{
			@"title" : block.title,
			@"category" : [NSNumber numberWithUnsignedInteger:block.category],
			@"alert" : [NSNumber numberWithUnsignedInteger:block.alert],
			@"start" : @{
				@"day" : [NSNumber numberWithInteger:[startComponents day]],
				@"month" : [NSNumber numberWithInteger:[startComponents month]],
				@"year" : [NSNumber numberWithInteger:[startComponents year]],
				@"hour" : [NSNumber numberWithInteger:[startComponents hour]],
				@"minute" : [NSNumber numberWithInteger:[startComponents minute]]
			},
			
			@"end" : @{
				@"day" : [NSNumber numberWithInteger:[endComponents day]],
				@"month" : [NSNumber numberWithInteger:[endComponents month]],
				@"year" : [NSNumber numberWithInteger:[endComponents year]],
				@"hour" : [NSNumber numberWithInteger:[endComponents hour]],
				@"minute" : [NSNumber numberWithInteger:[endComponents minute]]
			},
			
			@"days" : days
		};
		
		[ref setValue:blockData];
		
		// Set the entry's ID
		block.uid = ref.key;
	}
	
	// Add the block locally
	[self.blocks addObject:block];
	
	// TODO: Add upcoming events for the blocks in each week.
	[self addUpcoming:block];
}

- (void) addEvent: (Event*) event {
	
	// Add the event to the database
	if (self.currentUser) {
		Firebase* events = [[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"events"];
		Firebase* ref = [events childByAutoId];
		
		// Needed to separate out calendar components
		NSCalendar* calendar = [NSCalendar currentCalendar];
		NSDateComponents* startComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:event.start];
		NSDateComponents* endComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:event.end];
		
		NSDictionary* eventData = @{
			@"title" : event.title,
			@"category" : [NSNumber numberWithUnsignedInteger:event.category],
			@"alert" : [NSNumber numberWithUnsignedInteger:event.alert],
			@"start" : @{
				@"day" : [NSNumber numberWithInteger:[startComponents day]],
				@"month" : [NSNumber numberWithInteger:[startComponents month]],
				@"year" : [NSNumber numberWithInteger:[startComponents year]],
				@"hour" : [NSNumber numberWithInteger:[startComponents hour]],
				@"minute" : [NSNumber numberWithInteger:[startComponents minute]]
			},
		
			@"end" : @{
				@"day" : [NSNumber numberWithInteger:[endComponents day]],
				@"month" : [NSNumber numberWithInteger:[endComponents month]],
				@"year" : [NSNumber numberWithInteger:[endComponents year]],
				@"hour" : [NSNumber numberWithInteger:[endComponents hour]],
				@"minute" : [NSNumber numberWithInteger:[endComponents minute]]
			}
		};
		
		[ref setValue:eventData];
		
		// Set the entry's ID
		event.uid = ref.key;
	}
	
	// Add the event locally
	[self.events addObject:event];
	[self addUpcoming:event];
	
	// Add to the iOS calendar!
	[self addCalendarEvent:event];
}

- (void) addNotification: (Notification*) notification {
	
	// Add the notification to the database
	if (self.currentUser) {
		Firebase* notifications = [[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"notifications"];
		Firebase* ref = [notifications childByAutoId];
		
		// Needed to separate out calendar components
		NSCalendar* calendar = [NSCalendar currentCalendar];
		NSDateComponents* startComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:notification.start];
		
		NSDictionary* notificationData = @{
			@"title" : notification.title,
			@"category" : [NSNumber numberWithUnsignedInteger:notification.category],
			@"alert" : [NSNumber numberWithUnsignedInteger:notification.alert],
			@"start" : @{
				@"day" : [NSNumber numberWithInteger:[startComponents day]],
				@"month" : [NSNumber numberWithInteger:[startComponents month]],
				@"year" : [NSNumber numberWithInteger:[startComponents year]],
				@"hour" : [NSNumber numberWithInteger:[startComponents hour]],
				@"minute" : [NSNumber numberWithInteger:[startComponents minute]]
			}
		};
		
		[ref setValue:notificationData];
		
		// Set the entry's ID
		notification.uid = ref.key;
	}
	
	// Add the notification locally
	[self.notifications addObject:notification];
	[self addUpcoming:notification];
	
	// Add to the reminders list!
	[self addReminderNotification:notification];
}

- (void) addUpcoming: (Entry*) entry {
	Upcoming* upcoming = [Upcoming upcomingFromEntry:entry];
	[self.upcoming addObject:upcoming];
}

- (void) editBlock: (Block*) block {
	for (Block* b in self.blocks) {
		if ([b.uid isEqualToString:block.uid]) {
			b.title = block.title;
			b.category = block.category;
			b.alert = block.alert;
			b.days = block.days;
			b.start = block.start;
			b.end = block.end;
			
			// Update the database
			Firebase* blockRef = [[[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"blocks"] childByAppendingPath:block.uid];
			
			// Needed to separate out calendar components
			NSCalendar* calendar = [NSCalendar currentCalendar];
			NSDateComponents* startComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:block.start];
			NSDateComponents* endComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:block.end];
			
			NSMutableArray* days = [NSMutableArray arrayWithCapacity:0];
			[block.days enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
				[days addObject:[NSNumber numberWithUnsignedInteger:idx]];
			}];
			
			NSDictionary* blockData = @{
				@"title" : block.title,
				@"category" : [NSNumber numberWithUnsignedInteger:block.category],
				@"alert" : [NSNumber numberWithUnsignedInteger:block.alert],
				@"start" : @{
					@"day" : [NSNumber numberWithInteger:[startComponents day]],
					@"month" : [NSNumber numberWithInteger:[startComponents month]],
					@"year" : [NSNumber numberWithInteger:[startComponents year]],
					@"hour" : [NSNumber numberWithInteger:[startComponents hour]],
					@"minute" : [NSNumber numberWithInteger:[startComponents minute]]
				},
				
				@"end" : @{
					@"day" : [NSNumber numberWithInteger:[endComponents day]],
					@"month" : [NSNumber numberWithInteger:[endComponents month]],
					@"year" : [NSNumber numberWithInteger:[endComponents year]],
					@"hour" : [NSNumber numberWithInteger:[endComponents hour]],
					@"minute" : [NSNumber numberWithInteger:[endComponents minute]]
				},
				
				@"days" : days
			};
			
			// Update data, then return
			[blockRef setValue:blockData];
			return;
		}
	}
}

- (void) editEvent: (Event*) event {
	for (Event* e in self.events) {
		if ([e.uid isEqualToString:event.uid]) {
			e.title = event.title;
			e.category = event.category;
			e.alert = event.alert;
			e.start = event.start;
			e.end = event.end;
			
			// Update the database
			Firebase* eventRef = [[[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"events"] childByAppendingPath:event.uid];
			
			// Needed to separate out calendar components
			NSCalendar* calendar = [NSCalendar currentCalendar];
			NSDateComponents* startComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:event.start];
			NSDateComponents* endComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:event.end];
			
			NSDictionary* eventData = @{
				@"title" : event.title,
				@"category" : [NSNumber numberWithUnsignedInteger:event.category],
				@"alert" : [NSNumber numberWithUnsignedInteger:event.alert],
				@"start" : @{
					@"day" : [NSNumber numberWithInteger:[startComponents day]],
					@"month" : [NSNumber numberWithInteger:[startComponents month]],
					@"year" : [NSNumber numberWithInteger:[startComponents year]],
					@"hour" : [NSNumber numberWithInteger:[startComponents hour]],
					@"minute" : [NSNumber numberWithInteger:[startComponents minute]]
				},
				
				@"end" : @{
					@"day" : [NSNumber numberWithInteger:[endComponents day]],
					@"month" : [NSNumber numberWithInteger:[endComponents month]],
					@"year" : [NSNumber numberWithInteger:[endComponents year]],
					@"hour" : [NSNumber numberWithInteger:[endComponents hour]],
					@"minute" : [NSNumber numberWithInteger:[endComponents minute]]
				}
			};
			
			// Update data, then return
			[eventRef setValue:eventData];
			return;
		}
	}
}

- (void) editNotification: (Notification*) notification {
	for (Notification* n in self.notifications) {
		if ([n.uid isEqualToString:notification.uid]) {
			n.title = notification.title;
			n.category = notification.category;
			n.alert = notification.alert;
			n.start = notification.start;
			
			// Update the database
			Firebase* notificationRef = [[[[self.database childByAppendingPath:@"users"] childByAppendingPath:self.currentUser.uid] childByAppendingPath:@"notifications"] childByAppendingPath:notification.uid];
			
			// Needed to separate out calendar components
			NSCalendar* calendar = [NSCalendar currentCalendar];
			NSDateComponents* startComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:notification.start];
			
			NSDictionary* notificationData = @{
				@"title" : notification.title,
				@"category" : [NSNumber numberWithUnsignedInteger:notification.category],
				@"alert" : [NSNumber numberWithUnsignedInteger:notification.alert],
				@"start" : @{
					@"day" : [NSNumber numberWithInteger:[startComponents day]],
					@"month" : [NSNumber numberWithInteger:[startComponents month]],
					@"year" : [NSNumber numberWithInteger:[startComponents year]],
					@"hour" : [NSNumber numberWithInteger:[startComponents hour]],
					@"minute" : [NSNumber numberWithInteger:[startComponents minute]]
				}
			};
			
			// Update data, then return
			[notificationRef setValue:notificationData];
			return;
		}
	}
}

/**************************************/
// PRIVATE MEMBER FUNCTIONS
/**************************************/
- (void) loadUser:(ReloadUpcomingBlock) block {
	// Get general paths
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	
	// Load user from the disk
	self.currentUserFilepath = [documentsDirectory stringByAppendingPathComponent:(NSString*)kCurrentUserFile];
	NSDictionary* user = [NSDictionary dictionaryWithContentsOfFile:self.currentUserFilepath];
	if (user) {
		self.currentUser = [[User alloc] init];
		self.currentUser.name = user[@"name"];
		self.currentUser.email = user[@"email"];
		self.currentUser.username = user[@"username"];
		self.currentUser.password = user[@"password"];
		
		// Log the user in!
		[self.database authUser:self.currentUser.email password:[self restorePassword:self.currentUser.password] withCompletionBlock:^(NSError *error, FAuthData *authData) {
			if (error) {
				// There was an error logging into the account
			}
			
			else {
				// Get the user entry out of the database foo!
				NSString* uid = authData.uid;
				
				[self.database observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
					FDataSnapshot* user = [[snapshot childSnapshotForPath:@"users"] childSnapshotForPath:uid];
					self.currentUser.uid = uid;
					
					// Once the user is loaded, we can attempt to get their data from the database! Start with blocks
					FDataSnapshot* blockRef = [user childSnapshotForPath:@"blocks"];
					for (FDataSnapshot* b in [blockRef children]) {
						
						// Create the block
						Block* block = [[Block alloc] init];
						block.title = [b childSnapshotForPath:@"title"].value;
						block.category = [[b childSnapshotForPath:@"category"].value unsignedIntegerValue];
						block.alert = [[b childSnapshotForPath:@"alert"].value unsignedIntegerValue];
						
						// Reconstruct the dates
						NSCalendar* calendar = [NSCalendar currentCalendar];
						
						// Start date
						NSDictionary* start = [b childSnapshotForPath:@"start"].value;
						NSDateComponents* startComponents = [[NSDateComponents alloc] init];
						[startComponents setDay:[(NSNumber*)[start objectForKey:@"day"] integerValue]];
						[startComponents setMonth:[(NSNumber*)[start objectForKey:@"month"] integerValue]];
						[startComponents setYear:[(NSNumber*)[start objectForKey:@"year"] integerValue]];
						[startComponents setHour:[(NSNumber*)[start objectForKey:@"hour"] integerValue]];
						[startComponents setMinute:[(NSNumber*)[start objectForKey:@"minute"] integerValue]];
						block.start = [calendar dateFromComponents:startComponents];
						
						// Start date
						NSDictionary* end = [b childSnapshotForPath:@"end"].value;
						NSDateComponents* endComponents = [[NSDateComponents alloc] init];
						[endComponents setDay:[(NSNumber*)[end objectForKey:@"day"] integerValue]];
						[endComponents setMonth:[(NSNumber*)[end objectForKey:@"month"] integerValue]];
						[endComponents setYear:[(NSNumber*)[end objectForKey:@"year"] integerValue]];
						[endComponents setHour:[(NSNumber*)[end objectForKey:@"hour"] integerValue]];
						[endComponents setMinute:[(NSNumber*)[end objectForKey:@"minute"] integerValue]];
						block.end = [calendar dateFromComponents:endComponents];
						
						// Days
						NSArray* days = [b childSnapshotForPath:@"days"].value;
						NSMutableIndexSet* set = [[NSMutableIndexSet alloc] init];
						for (NSNumber* i in days) {
							[set addIndex:[i unsignedIntegerValue]];
						}
						block.days = set;
						
						// Set the ID of the entry
						block.uid = b.key;
						
						// Add the block locally
						[self.blocks addObject:block];
						
						// TODO: Add upcoming events for the blocks in each week.
						[self addUpcoming:block];
					}
					
					// Now, let's do events!
					FDataSnapshot* eventRef = [user childSnapshotForPath:@"events"];
					for (FDataSnapshot* b in [eventRef children]) {
						
						// Create the block
						Event* event = [[Event alloc] init];
						event.title = [b childSnapshotForPath:@"title"].value;
						event.category = [[b childSnapshotForPath:@"category"].value unsignedIntegerValue];
						event.alert = [[b childSnapshotForPath:@"alert"].value unsignedIntegerValue];
						
						// Reconstruct the dates
						NSCalendar* calendar = [NSCalendar currentCalendar];
						
						// Start date
						NSDictionary* start = [b childSnapshotForPath:@"start"].value;
						NSDateComponents* startComponents = [[NSDateComponents alloc] init];
						[startComponents setDay:[(NSNumber*)[start objectForKey:@"day"] integerValue]];
						[startComponents setMonth:[(NSNumber*)[start objectForKey:@"month"] integerValue]];
						[startComponents setYear:[(NSNumber*)[start objectForKey:@"year"] integerValue]];
						[startComponents setHour:[(NSNumber*)[start objectForKey:@"hour"] integerValue]];
						[startComponents setMinute:[(NSNumber*)[start objectForKey:@"minute"] integerValue]];
						event.start = [calendar dateFromComponents:startComponents];
						
						// Start date
						NSDictionary* end = [b childSnapshotForPath:@"end"].value;
						NSDateComponents* endComponents = [[NSDateComponents alloc] init];
						[endComponents setDay:[(NSNumber*)[end objectForKey:@"day"] integerValue]];
						[endComponents setMonth:[(NSNumber*)[end objectForKey:@"month"] integerValue]];
						[endComponents setYear:[(NSNumber*)[end objectForKey:@"year"] integerValue]];
						[endComponents setHour:[(NSNumber*)[end objectForKey:@"hour"] integerValue]];
						[endComponents setMinute:[(NSNumber*)[end objectForKey:@"minute"] integerValue]];
						event.end = [calendar dateFromComponents:endComponents];
						
						// Set the ID of the entry
						event.uid = b.key;
						
						// Add the block locally
						[self.events addObject:event];
						
						// Add the upcoming entry
						[self addUpcoming:event];
					}
					
					// We'll do notifications last!
					FDataSnapshot* notificationRef = [user childSnapshotForPath:@"notifications"];
					for (FDataSnapshot* b in [notificationRef children]) {
						
						// Create the block
						Notification* notification = [[Notification alloc] init];
						notification.title = [b childSnapshotForPath:@"title"].value;
						notification.category = [[b childSnapshotForPath:@"category"].value unsignedIntegerValue];
						notification.alert = [[b childSnapshotForPath:@"alert"].value unsignedIntegerValue];
						
						// Reconstruct the dates
						NSCalendar* calendar = [NSCalendar currentCalendar];
						
						// Start date
						NSDictionary* start = [b childSnapshotForPath:@"start"].value;
						NSDateComponents* startComponents = [[NSDateComponents alloc] init];
						[startComponents setDay:[(NSNumber*)[start objectForKey:@"day"] integerValue]];
						[startComponents setMonth:[(NSNumber*)[start objectForKey:@"month"] integerValue]];
						[startComponents setYear:[(NSNumber*)[start objectForKey:@"year"] integerValue]];
						[startComponents setHour:[(NSNumber*)[start objectForKey:@"hour"] integerValue]];
						[startComponents setMinute:[(NSNumber*)[start objectForKey:@"minute"] integerValue]];
						notification.start = [calendar dateFromComponents:startComponents];
						
						// Set the ID of the entry
						notification.uid = b.key;
						
						// Add the block locally
						[self.notifications addObject:notification];
						
						// Add the upcoming entry
						[self addUpcoming:notification];
					}
					
					if (block) {
						block ();
					}
				}];
			}
		}];
	}
}

- (void) setupArrays {
	/*
	// Get general paths
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	
	// Load blocks
	self.blocksFilepath = [documentsDirectory stringByAppendingPathComponent:(NSString*)kBlockDataFile];
	self.blocks = [NSMutableArray arrayWithContentsOfFile:self.blocksFilepath];
	
	// Load events
	self.eventsFilepath = [documentsDirectory stringByAppendingPathComponent:(NSString*)kEventDataFile];
	self.blocks = [NSMutableArray arrayWithContentsOfFile:self.eventsFilepath];
	
	// Load notifications
	self.notificationsFilepath = [documentsDirectory stringByAppendingPathComponent:(NSString*)kNotificationDataFile];
	self.blocks = [NSMutableArray arrayWithContentsOfFile:self.notificationsFilepath];
	*/
	
	if (!self.blocks) {
		self.blocks = [NSMutableArray arrayWithCapacity:0];
	}
	
	if (!self.events) {
		self.events = [NSMutableArray arrayWithCapacity:0];
	}
	
	if (!self.notifications) {
		self.notifications = [NSMutableArray arrayWithCapacity:0];
	}
	
	self.upcoming = [NSMutableArray arrayWithCapacity:0];
}

- (void) loadCategories {
	// Create array and load initial categories
	self.categories = [NSMutableArray arrayWithCapacity:0];
	[self.categories addObject:[Category categoryFromColor:[UIColor darkGrayColor] withName:@"Default"]];
	[self.categories addObject:[Category categoryFromColor:[UIColor blueColor] withName:@"School"]];
	[self.categories addObject:[Category categoryFromColor:[UIColor greenColor] withName:@"Work"]];
	[self.categories addObject:[Category categoryFromColor:[UIColor redColor] withName:@"Personal"]];
	[self.categories addObject:[Category categoryFromColor:[UIColor orangeColor] withName:@"Misc"]];
}

- (void) loadQuotes {
	// Create array
	self.quotes = [NSMutableArray arrayWithCapacity:0];
	
	// Pull quotes from the database
	[self.database observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
		FDataSnapshot* quoteRef = [snapshot childSnapshotForPath:@"quotes"];
		for (FDataSnapshot* q in [quoteRef children]) {
			Quote* quote = [Quote quoteFromQuote:[q childSnapshotForPath:@"quote"].value withAuthor:[q childSnapshotForPath:@"author"].value];
			[self.quotes addObject:quote];
		}
	}];
}

- (void) loadAlerts {
	// Create array
	self.alerts = [NSMutableArray arrayWithCapacity:0];
	[self.alerts addObject:[Alert alertWithTitle:@"None" withTime:0]];
	[self.alerts addObject:[Alert alertWithTitle:@"At time of event" withTime:0]];
	[self.alerts addObject:[Alert alertWithTitle:@"5 minutes before" withTime:-300]];
	[self.alerts addObject:[Alert alertWithTitle:@"15 minutes before" withTime:-900]];
	[self.alerts addObject:[Alert alertWithTitle:@"30 minutes before" withTime:-1800]];
	[self.alerts addObject:[Alert alertWithTitle:@"1 hour before" withTime:-3600]];
	[self.alerts addObject:[Alert alertWithTitle:@"2 hours before" withTime:-7200]];
}

- (void) setupFirebase {
	self.database = [[Firebase alloc] initWithUrl:(NSString*)kFirebaseURL];
}

// Saving and deleting users
- (void) saveUser {
	
	NSDictionary* data = nil;
	if (self.currentUser) {
		data = @{
			@"name": self.currentUser.name,
			@"email": self.currentUser.email,
			@"username": self.currentUser.username,
			@"password": self.currentUser.password
		};
	}
	
	[data writeToFile:self.currentUserFilepath atomically:YES];
}

- (void) removeUser {
	self.currentUser = nil;
	[[NSFileManager defaultManager] removeItemAtPath:self.currentUserFilepath error:nil];
}

// Password hashing
- (NSData*) hashPassword: (NSString*) password {
	
	NSData* passData = [password dataUsingEncoding:NSUTF8StringEncoding];
	NSData* cipher = [passData AES256EncryptWithKey:(NSString*)kEncryptionPassword];
	return cipher;
}

- (NSString*) restorePassword: (NSData*) hashedPassword {
	
	NSData* passData = [hashedPassword AES256DecryptWithKey:(NSString*)kEncryptionPassword];
	NSString* password = [[NSString alloc] initWithData:passData encoding:NSUTF8StringEncoding];
	return password;
}

// Reminders and events
- (void) addCalendarEvent:(Event*) event {

	if (!self.calendar) {
		return;
	}
	
	if (!self.isAccessToEventStoreGranted) {
		return;
	}
	
	EKEvent* ev = [EKEvent eventWithEventStore:self.eventStore];
	ev.title = event.title;
	ev.startDate = event.start;
	ev.endDate = event.end;
	ev.calendar = self.calendar;
	
	// TODO: Compute time interval for alarm based on input value
	Alert* alert = [self.alerts objectAtIndex:event.alert];
	NSTimeInterval alarm = alert.delay;
	[ev addAlarm:[EKAlarm alarmWithRelativeOffset:alarm]];
	
	NSError* error = nil;
	BOOL success = [self.eventStore saveEvent:ev span:EKSpanThisEvent error:&error];
	if (!success) {}
}

- (void) removeCalendarEvent:(Event*) event {
	
	if (!self.calendar) {
		return;
	}
	
	if (!self.isAccessToEventStoreGranted) {
		return;
	}
	
	[self.eventStore enumerateEventsMatchingPredicate:[self.eventStore predicateForEventsWithStartDate:event.start endDate:event.end calendars:[NSArray arrayWithObjects:self.calendar, nil]] usingBlock:^(EKEvent * _Nonnull ev, BOOL * _Nonnull stop) {
		if ([ev.title isEqualToString:event.title]) {
			NSError* error = nil;
			BOOL success = [self.eventStore removeEvent:ev span:EKSpanThisEvent error:&error];
			if (!success) {}
		}
	}];
	
	NSError* commitErr = nil;
	BOOL success = [self.eventStore commit:&commitErr];
	if (!success) {}
}

- (void) addReminderNotification:(Notification*) notification {
	
	if (!self.reminders) {
		return;
	}
	
	if (!self.isAccessToEventStoreGranted) {
		return;
	}
	
	EKReminder* reminder = [EKReminder reminderWithEventStore:self.eventStore];
	reminder.title = notification.title;
	reminder.calendar = self.reminders;
 
	// TODO: Compute time interval for alarm based on input value
	Alert* alert = [self.alerts objectAtIndex:notification.alert];
	NSTimeInterval alarm = alert.delay;
	[reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:[NSDate dateWithTimeInterval:alarm sinceDate:notification.start]]];
	
	NSError* error = nil;
	BOOL success = [self.eventStore saveReminder:reminder commit:YES error:&error];
	if (!success) {}
}

- (void) removeReminderNotification:(Notification*) notification {
	
	if (!self.reminders) {
		return;
	}
	
	if (!self.isAccessToEventStoreGranted) {
		return;
	}
	
	[self.eventStore fetchRemindersMatchingPredicate:[self.eventStore predicateForRemindersInCalendars:[NSArray arrayWithObjects:self.reminders, nil]] completion:^(NSArray* reminders) {
		
		// Loop through and remove all reminders matching the notification's name
		for (EKReminder* reminder in reminders) {
			if ([reminder.title isEqualToString:notification.title]) {
				NSError* error = nil;
				BOOL success = [self.eventStore removeReminder:reminder commit:NO error:&error];
				if (!success) {}
			}
		}
		
		NSError* commitErr = nil;
		BOOL success = [self.eventStore commit:&commitErr];
		if (!success) {}
	}];
}

// Event kit
- (void) setupEvents {
	
	// Set up event system
	self.eventStore = [[EKEventStore alloc] init];
	[self updateAuthorizationStatusToAccessEventStore];
	
	if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
		[self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
			if (granted) {
				
				// Set up calendar (for events and eventually blocks!)
				if (!self.calendar) {
					
					NSArray* calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
					NSString* calendarTitle = @"New Day";
					NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
					NSArray* filtered = [calendars filteredArrayUsingPredicate:predicate];
					
					if ([filtered count]) {
						self.calendar = [filtered firstObject];
					}
					
					else {
						self.calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
						self.calendar.title = calendarTitle;
						self.calendar.source = self.eventStore.defaultCalendarForNewEvents.source;
						
						NSError* calendarErr = nil;
						BOOL calendarSuccess = [self.eventStore saveCalendar:self.calendar commit:YES error:&calendarErr];
						if (!calendarSuccess) {}
					}
				}
				
				// Set up reminders (for notifications!)
				if (!self.reminders) {
					
					NSArray* calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
					NSString* calendarTitle = @"New Day";
					NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
					NSArray* filtered = [calendars filteredArrayUsingPredicate:predicate];
					
					if ([filtered count]) {
						self.reminders = [filtered firstObject];
					}
					
					else {
						self.reminders = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
						self.reminders.title = calendarTitle;
						self.reminders.source = self.eventStore.defaultCalendarForNewReminders.source;
						
						NSError* calendarErr = nil;
						BOOL calendarSuccess = [self.eventStore saveCalendar:self.reminders commit:YES error:&calendarErr];
						if (!calendarSuccess) {}
					}
				}
			}
			
			else {
				self.calendar = nil;
				self.reminders = nil;
			}
		}];
	}
}
- (void)updateAuthorizationStatusToAccessEventStore {

	EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
	switch (authorizationStatus) {
		case EKAuthorizationStatusDenied:
		case EKAuthorizationStatusRestricted: {
			self.isAccessToEventStoreGranted = NO;
			break;
		}
		
		case EKAuthorizationStatusAuthorized:
			self.isAccessToEventStoreGranted = YES;
			break;
			
		case EKAuthorizationStatusNotDetermined: {
			__weak ApplicationManager* weakSelf = self;
			[self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					weakSelf.isAccessToEventStoreGranted = granted;
				});
			}];
			break;
		}
	}
}

@end
