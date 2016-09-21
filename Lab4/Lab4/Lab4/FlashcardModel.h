//
//  FlashcardModel.h
//  Lab4
//
//  Created by Colin Cammarano on 3/15/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlashcardModel : NSObject

// Init method
- (id) init;

// Public member methods
+ (instancetype) sharedModel;
- (NSDictionary*) randomFlashcard;
- (NSUInteger) numberOfFlashcards;
- (NSDictionary*) flashcardAtIndex: (NSUInteger) index;
- (void) removeFlashcardAtIndex: (NSUInteger) index;
- (void) insertFlashcard: (NSDictionary*) flashcard;
- (void) insertFlashcard: (NSString*) question answer: (NSString*) answer;
- (void) insertFlashcard: (NSDictionary*) flashcard atIndex: (NSUInteger) index;
- (void) insertFlashcard: (NSString*) question  answer: (NSString *) answer atIndex: (NSUInteger) index;
- (NSDictionary *) nextFlashcard;
- (NSDictionary *) prevFlashcard;

@end
