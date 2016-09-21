//
//  Lab4Tests.m
//  Lab4Tests
//
//  Created by Colin Cammarano on 3/15/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FlashcardModel.h"

@interface Lab4Tests : XCTestCase
	@property (strong, nonatomic) FlashcardModel* flashcardModel;
@end

@implementation Lab4Tests

- (void)setUp {
    [super setUp];
	
	// Put setup code here. This method is called before the invocation of each test method in the class.
	self.flashcardModel = [[FlashcardModel alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInsertFlashcard {
	NSDictionary* test = [NSDictionary dictionaryWithObject:@"Test" forKey:@"Test"];
	[_flashcardModel insertFlashcard:test];
	
	XCTAssertEqual(7, [_flashcardModel numberOfFlashcards]);
	XCTAssertEqualObjects(test, [_flashcardModel flashcardAtIndex:6]);
}

- (void)testInsertFlashcardAtIndex {
	NSDictionary* test = [NSDictionary dictionaryWithObject:@"Test" forKey:@"Test"];
	[_flashcardModel insertFlashcard:test atIndex:2];
	
	XCTAssertEqual(7, [_flashcardModel numberOfFlashcards]);
	XCTAssertEqualObjects(test, [_flashcardModel flashcardAtIndex:2]);
	
	// Try another index that's too big
	[_flashcardModel insertFlashcard:test atIndex:21];
	
	XCTAssertEqual(7, [_flashcardModel numberOfFlashcards]);
}

- (void)testInsertFlashcardWithAnswer {
	[_flashcardModel insertFlashcard:@"Test" answer:@"Test"];
	
	XCTAssertEqual(7, [_flashcardModel numberOfFlashcards]);
}

- (void)testInsertFlashcardWithAnswerAtIndex {
	[_flashcardModel insertFlashcard:@"Test" answer:@"Test" atIndex:2];
	
	XCTAssertEqual(7, [_flashcardModel numberOfFlashcards]);
	XCTAssertEqual(@"Test", [[_flashcardModel flashcardAtIndex:2] valueForKey:@"Test"]);
}

- (void)testRemoveFlashcardAtIndex {
	[_flashcardModel removeFlashcardAtIndex:2];
	
	XCTAssertEqual(5, [_flashcardModel numberOfFlashcards]);
	
	// Try another index that's too large
	[_flashcardModel removeFlashcardAtIndex:7];

	XCTAssertEqual(5, [_flashcardModel numberOfFlashcards]);
}

@end
