//
//  ViewController.m
//  Lab4
//
//  Created by Colin Cammarano on 3/15/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ViewController.h"
#import "FlashcardModel.h"

@interface ViewController ()
	@property (strong, nonatomic) FlashcardModel* flashcardModel;
	@property (strong, nonatomic) NSDictionary* currentFlashcard;
	@property (strong, nonatomic) NSDictionary* defaultFlashcard;

	// IBOutlets
	@property (weak, nonatomic) IBOutlet UILabel *labelDisplay;

	// Audio
	@property (strong, nonatomic) AVAudioPlayer* fadeinAudioPlayer;
	@property (strong, nonatomic) AVAudioPlayer* answerAudioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Set up the model and display the initial question
	self.flashcardModel = [FlashcardModel sharedModel];
	[self displayInitialFlashcard];
	
	// Add gesture recognizers
	UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
	[self.view addGestureRecognizer:singleTap];
	
	UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
	doubleTap.numberOfTapsRequired = 2;
	[self.view addGestureRecognizer:doubleTap];
	
	UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:swipeLeft];
	
	UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:swipeRight];
	
	// Prevent double taps from being recognized as single taps
	[singleTap requireGestureRecognizerToFail:doubleTap];
	
	// Set up audio
	NSString* fadePath = [NSString stringWithFormat:@"%@/fadein.wav", [[NSBundle mainBundle] resourcePath]];
	NSURL* fadeURL = [NSURL fileURLWithPath:fadePath];
	NSError* error;
	
	self.fadeinAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fadeURL error:&error];
	[self.fadeinAudioPlayer prepareToPlay];
	
	NSString* answerPath = [NSString stringWithFormat:@"%@/TaDa.wav", [[NSBundle mainBundle] resourcePath]];
	NSURL* answerURL = [NSURL fileURLWithPath:answerPath];
	
	self.answerAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:answerURL error:&error];
	[self.answerAudioPlayer prepareToPlay];
	
	// Get file path
	#if TARGET_IPHONE_SIMULATOR
	NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
	#endif
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// Gesture callbacks
- (void) onSingleTap: (UITapGestureRecognizer*) recognizer {
	[self displayRandomFlashcard];
}

- (void) onDoubleTap: (UITapGestureRecognizer*) recognizer {
	// Play the sound!
	[self.answerAudioPlayer play];
	
	[UIView animateWithDuration:1.0
	animations:^{
		_labelDisplay.alpha = 0;
	}
	completion:^(BOOL finished) {
		NSString* key = [[_currentFlashcard allKeys] objectAtIndex: 0];
		_labelDisplay.text = [_currentFlashcard objectForKey:key];
		_labelDisplay.textColor = [UIColor redColor];
		_labelDisplay.alpha = 0;
		[UIView animateWithDuration:1.0 animations:^{ _labelDisplay.alpha = 1; }];
	}];
}

- (void) onSwipeLeft: (UISwipeGestureRecognizer*) recognizer {
	// Show the card
	if ([_flashcardModel numberOfFlashcards] > 0) {
		_currentFlashcard = [_flashcardModel nextFlashcard];
	}
	
	else {
		_currentFlashcard = _defaultFlashcard;
	}
	[self displayCurrentFlashcard];
}

- (void) onSwipeRight: (UISwipeGestureRecognizer*) recognizer {
	// Show the card
	if ([_flashcardModel numberOfFlashcards] > 0) {
		_currentFlashcard = [_flashcardModel prevFlashcard];
	}
	
	else {
		_currentFlashcard = _defaultFlashcard;
	}
	[self displayCurrentFlashcard];
}

// Handle shakes
- (void) motionEnded: (UIEventSubtype) motion withEvent:(UIEvent*) event {
	if (UIEventSubtypeMotionShake) {
		[self displayRandomFlashcard];
	}
}

// Private methods
- (void) displayCurrentFlashcard {
	// Play the sound!
	[self.fadeinAudioPlayer play];
	
	// Show the card!
	[UIView animateWithDuration:1.0
	animations:^{
		_labelDisplay.alpha = 0;
	}
	completion:^(BOOL finished) {
		_labelDisplay.text = [[_currentFlashcard allKeys] objectAtIndex: 0];
		_labelDisplay.textColor = [UIColor blackColor];
		_labelDisplay.alpha = 0;
		[UIView animateWithDuration:1.0 animations:^{ _labelDisplay.alpha = 1; }];
	}];
}

- (void) displayRandomFlashcard {
	// Show the card
	if ([_flashcardModel numberOfFlashcards] > 0) {
		_currentFlashcard = [_flashcardModel randomFlashcard];
	}
	
	else {
		_currentFlashcard = _defaultFlashcard;
	}
	
	[self displayCurrentFlashcard];
}

- (void) displayInitialFlashcard {
	
	// Create default flashcard
	_defaultFlashcard = [NSDictionary dictionaryWithObject:@"Please add more flashcards." forKey:@"There are no more flashcards."];
	// Show the card
	if ([_flashcardModel numberOfFlashcards] > 0) {
		_currentFlashcard = [_flashcardModel flashcardAtIndex: 0];
	}
	
	else {
		_currentFlashcard = _defaultFlashcard;
	}
	
	_labelDisplay.text = [[_currentFlashcard allKeys] objectAtIndex: 0];
	_labelDisplay.textColor = [UIColor blackColor];
	_labelDisplay.alpha = 0;
	[UIView animateWithDuration:1.0 animations:^{ _labelDisplay.alpha = 1; }];
}

@end
