//
//  UpcomingDetailViewController.h
//  NewDay
//
//  Created by Colin Cammarano on 5/4/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationManager.h"
#import "UpcomingViewController.h"

@interface UpcomingDetailViewController : UIViewController
	@property (strong, nonatomic) Upcoming* upcoming;
	@property (strong, nonatomic) UpcomingViewController* uView;
@end
