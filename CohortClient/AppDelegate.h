//
//  AppDelegate.h
//  CohortClient
//
//  Created by Jacob Niedzwiecki on 2015-12-13.
//  Copyright © 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cohort.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *mainViewController;
@property (strong, nonatomic) CHSession *cohortSession;

@end

