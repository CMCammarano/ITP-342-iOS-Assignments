//
//  NewDayTests.m
//  NewDayTests
//
//  Created by Colin Cammarano on 5/1/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ApplicationManager.h"

@interface NewDayTests : XCTestCase
	@property (strong, nonatomic) ApplicationManager* manager;
@end

@implementation NewDayTests

- (void)setUp {
    [super setUp];
	
	self.manager = [ApplicationManager instance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**************************************/
// GENERAL TESTS
/**************************************/
- (void)testSingletonAccessor {
	ApplicationManager* singleton = [ApplicationManager instance];
	XCTAssertNotNil (singleton);
}

/**************************************/
// USER ACCOUNT TESTS
/**************************************/
- (void)testRegisterUserValid {
	[self.manager registerUser:@"Colin Cammarano" withUsername:@"CMCammarano" withEmail:@"cammaran@usc.edu" withPassword:@"thisisapassword" withBlock:^{
		XCTAssertNotNil(self.manager.currentUser);
	}];
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testLogoff {
	[self.manager loginUser:@"cammaran@usc.edu" withPassword:@"thisisapassword" withBlock:^{}];
	[self.manager logoff];
	
	XCTAssertNil(self.manager.currentUser);
}

- (void)testRegisterUserInvalidEmailNoDomain {
	[self.manager registerUser:@"Colin Cammarano" withUsername:@"CMCammarano" withEmail:@"cammaran" withPassword:@"thisisapassword" withBlock:^{}];
	
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testRegisterUserInvalidEmailNoUsername {
	[self.manager registerUser:@"Colin Cammarano" withUsername:@"CMCammarano" withEmail:@"@usc.edu" withPassword:@"thisisapassword" withBlock:^{}];
	
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testRegisterUserInvalidEmailNull {
	[self.manager registerUser:@"Colin Cammarano" withUsername:@"CMCammarano" withEmail:nil withPassword:@"thisisapassword" withBlock:^{}];
	
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testRegisterUserInvalidPassword {
	[self.manager registerUser:@"Colin Cammarano" withUsername:@"CMCammarano" withEmail:@"cammaran@usc.edu" withPassword:@"" withBlock:^{}];
	
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testRegisterUserInvalidPasswordNull {
	[self.manager registerUser:@"Colin Cammarano" withUsername:@"CMCammarano" withEmail:@"cammaran@usc.edu" withPassword:nil withBlock:^{}];
	
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testLoginUserValid {
	[self.manager loginUser:@"cammaran@usc.edu" withPassword:@"thisisapassword" withBlock:^{
		XCTAssertNotNil(self.manager.currentUser);
	}];
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testLoginUserInvalidEmailNoDomain {
	[self.manager loginUser:@"cammaran" withPassword:@"thisisapassword" withBlock:^{}];
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testLoginUserInvalidEmailNoUsername {
	[self.manager loginUser:@"@usc.edu" withPassword:@"thisisapassword" withBlock:^{}];
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testLoginUserInvalidEmailNil {
	[self.manager loginUser:nil withPassword:@"thisisapassword" withBlock:^{}];
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}


- (void)testLoginUserInvalidPassword {
	[self.manager loginUser:@"cammaran@usc.edu" withPassword:@"" withBlock:^{}];
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testLoginUserNilPassword {
	[self.manager loginUser:@"cammaran@usc.edu" withPassword:nil withBlock:^{}];
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

- (void)testLoginUnregisteredUser {
	[self.manager loginUser:@"iamnotauser@test.com" withPassword:@"pasword123" withBlock:^{}];
	XCTAssertNil(self.manager.currentUser);
	
	// Logoff after every test to ensure that the user data is cleared.
	[self.manager logoff];
}

/**************************************/
// CALENDAR TESTS
/**************************************/
- (void)testAddBlock {
	// Set a default value
	XCTAssertEqual(0, [self.manager numberOfUpcomingEvents]);
	
	// Create entry and add it
	Block* block = [[Block alloc] init];
	[self.manager addBlock:block];
	XCTAssertEqual(1, [self.manager numberOfUpcomingEvents]);
}

- (void)testAddEvent {
	// Set a default value
	XCTAssertEqual(1, [self.manager numberOfUpcomingEvents]);
	
	// Create entry and add it
	Event* event = [[Event alloc] init];
	[self.manager addEvent:event];
	XCTAssertEqual(2, [self.manager numberOfUpcomingEvents]);
}

- (void)testAddNotification {
	// Set a default value
	XCTAssertEqual(2, [self.manager numberOfUpcomingEvents]);
	
	// Create entry and add it
	Notification* not = [[Notification alloc] init];
	[self.manager addNotification:not];
	XCTAssertEqual(3, [self.manager numberOfUpcomingEvents]);
}

- (void)testRemoveUpcoming {
	// Set a default value
	XCTAssertEqual(0, [self.manager numberOfUpcomingEvents]);
	
	// Create block
	Block* block = [[Block alloc] init];
	[self.manager addBlock:block];
	XCTAssertEqual(1, [self.manager numberOfUpcomingEvents]);
	
	// Remove block
	[self.manager removeUpcomingEventAtIndex:0];
	XCTAssertEqual(0, [self.manager numberOfUpcomingEvents]);
}

- (void)testRemoveUpcomingInvalid {
	// Set a default value
	XCTAssertEqual(0, [self.manager numberOfUpcomingEvents]);
	
	// Create block
	Block* block = [[Block alloc] init];
	[self.manager addBlock:block];
	XCTAssertEqual(1, [self.manager numberOfUpcomingEvents]);
	
	// Remove block
	[self.manager removeUpcomingEventAtIndex:10];
	XCTAssertEqual(1, [self.manager numberOfUpcomingEvents]);
}
@end
