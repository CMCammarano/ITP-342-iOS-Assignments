//
//  FlashcardModel.m
//  Lab4
//
//  Created by Colin Cammarano on 3/15/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import "FlashcardModel.h"

@interface FlashcardModel ()
	@property (strong, nonatomic) NSMutableArray* flashcards;
	@property (nonatomic) NSInteger currentIndex;
	@property (strong, nonatomic) NSString* filepath;
@end

@implementation FlashcardModel

// Constant implementations
const NSString* kFlashcardKeyOne = @"Is this a question?";
const NSString* kFlashcardKeyTwo = @"Is this another question?";
const NSString* kFlashcardKeyThree = @"Is this yet another question?";
const NSString* kFlashcardKeyFour = @"Is this the fourth question?";
const NSString* kFlashcardKeyFive = @"Is this the fifth question?";
const NSString* kFlashcardKeySix = @"Is this the sixth question?";

// Initializer method
- (id) init {
	if (self = [super init]) {
		
		// Get the file location for our flashcard plist
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentsDirectory = [paths objectAtIndex:0];
		self.filepath = [documentsDirectory stringByAppendingPathComponent:kFlashcardFilename];
		
		// Initialize the array with our flashcards
		self.flashcards = [NSMutableArray arrayWithContentsOfFile:self.filepath];
		if (!self.flashcards) {
			self.flashcards = [[NSMutableArray alloc] initWithObjects:
							   [NSDictionary dictionaryWithObject:@"Yep!" forKey:kFlashcardKeyOne],
							   [NSDictionary dictionaryWithObject:@"Yes!" forKey:kFlashcardKeyTwo],
							   [NSDictionary dictionaryWithObject:@"Correct!" forKey:kFlashcardKeyThree],
							   [NSDictionary dictionaryWithObject:@"No! I mean, yes!" forKey:kFlashcardKeyFour],
							   [NSDictionary dictionaryWithObject:@"Yes! I ran out of witty remarks!" forKey:kFlashcardKeyFive],
							   [NSDictionary dictionaryWithObject:@"Yes! And now I really don't know what else to say!" forKey:kFlashcardKeySix],
							   nil];
		}
		
	}
	return self;
}

// Member methods
+ (instancetype) sharedModel {
	static FlashcardModel* singleton = nil;
	if (singleton == nil) {
		singleton = [[self alloc] init];
	}
	
	return singleton;
}

- (NSDictionary*) randomFlashcard {
	
	self.currentIndex = (NSInteger)arc4random_uniform((int)[self numberOfFlashcards]);
	return [self flashcardAtIndex: self.currentIndex];
}

- (NSUInteger) numberOfFlashcards {
	return [self.flashcards count];
}

- (NSDictionary*) flashcardAtIndex: (NSUInteger) index {
	self.currentIndex = index;
	return [self.flashcards objectAtIndex: index];
}

- (void) removeFlashcardAtIndex: (NSUInteger) index {
	if (index < [self numberOfFlashcards]) {
		[self.flashcards removeObjectAtIndex: index];
		[self save];
	}
}

- (void) insertFlashcard: (NSDictionary*) flashcard {
	[self.flashcards addObject: flashcard];
	[self save];
}

- (void) insertFlashcard: (NSString*) question answer: (NSString*) answer {
	NSDictionary* flashcard = [NSDictionary dictionaryWithObject: answer forKey: question];
	[self.flashcards addObject: flashcard];
	[self save];
}

- (void) insertFlashcard: (NSDictionary*) flashcard atIndex: (NSUInteger) index {
	if (index <= [self numberOfFlashcards]) {
		[self.flashcards insertObject: flashcard atIndex: index];
		[self save];
	}
}

- (void) insertFlashcard: (NSString*) question  answer: (NSString *) answer atIndex: (NSUInteger) index {
	if (index <= [self numberOfFlashcards]) {
		NSDictionary* flashcard = [NSDictionary dictionaryWithObject: answer forKey: question];
		[self.flashcards insertObject: flashcard atIndex: index];
		[self save];
	}
}

- (NSDictionary *) nextFlashcard {
	self.currentIndex++;
	if (self.currentIndex >= [self numberOfFlashcards]) {
		self.currentIndex = 0;
	}
	
	return [self.flashcards objectAtIndex: self.currentIndex];
}

- (NSDictionary *) prevFlashcard {
	self.currentIndex--;
	if (self.currentIndex < 0) {
		self.currentIndex = [self numberOfFlashcards] - 1;
	}
	
	return [self.flashcards objectAtIndex: self.currentIndex];
}

// Saving and loading
- (void)save {
	[self.flashcards writeToFile:self.filepath atomically:YES];
}

@end
