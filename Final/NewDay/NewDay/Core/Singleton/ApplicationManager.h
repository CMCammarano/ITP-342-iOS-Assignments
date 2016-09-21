//
//  ApplicationManager.h
//  NewDay
//
//  Created by Colin Cammarano on 4/28/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Upcoming.h"
#import "User.h"
#import "Block.h"
#import "Event.h"
#import "Notification.h"
#import "Category.h"
#import "Quote.h"
#import "Alert.h"

typedef void(^ReloadUpcomingBlock) ();
typedef void(^LoginCompletionBlock) ();
typedef void(^RegisterCompletionBlock) ();

@interface ApplicationManager : NSObject
	/**************************************/
	// SINGLETON
	/**************************************/
	+ (instancetype) instance;

	/**************************************/
	// PUBLIC PROPERTIES
	/**************************************/
	@property (strong, nonatomic) User* currentUser;

	/**************************************/
	// PUBLIC MEMBER METHODS
	/**************************************/
	- (instancetype) init;

	// Upcoming events
	- (NSUInteger) numberOfUpcomingEvents;
	- (Upcoming*) getUpcomingEventAtIndex: (NSUInteger) index;
	- (void) removeUpcomingEventAtIndex: (NSUInteger) index;

	// Categories
	- (NSUInteger) numberOfCategories;
	- (Category*) getCategoryAtIndex: (NSUInteger) index;

	// Alerts
	- (NSUInteger) numberOfAlerts;
	- (Alert*) getAlertAtIndex: (NSUInteger) index;

	// Users
	- (void) logoff;
	- (void) loginUser: (NSString*) email withPassword: (NSString*) password withBlock: (LoginCompletionBlock) block;
	- (void) registerUser: (NSString*) name withUsername: (NSString*) username withEmail: (NSString*) email withPassword: (NSString*) password withBlock: (RegisterCompletionBlock) block;

	// Quotes
	- (Quote*) randomQuote;

	// Adding and editing entries
	- (void) addBlock: (Block*) block;
	- (void) addEvent: (Event*) event;
	- (void) addNotification: (Notification*) notification;

	- (void) editBlock: (Block*) block;
	- (void) editEvent: (Event*) event;
	- (void) editNotification: (Notification*) notification;

	// Hack to update upcoming events array
	- (void) loadUser:(ReloadUpcomingBlock) block;
@end
