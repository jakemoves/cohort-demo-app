//
//  ViewController.h
//  CohortClient
//
//  Created by Jacob Niedzwiecki on 2015-12-13.
//  Copyright © 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cohort.h"

@interface ViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) CHSession *session;
@property (strong, nonatomic) CHEvent *event;
@property (strong, nonatomic) CHSoundCue *bgAudioCue;

@property (strong, nonatomic) NSMutableDictionary *flags;

// UI
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *checkInView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkInViewLeading;
@property (weak, nonatomic) IBOutlet UILabel *lblParticipantIndexCheckIn;
@property (strong, nonatomic) IBOutlet UIStepper *stepperParticipantIndex;
@property (strong, nonatomic) IBOutlet UISwitch *checkInToggle;
@property (weak, nonatomic) IBOutlet UIView *checkedInView;
@property (weak, nonatomic) IBOutlet UILabel *lblParticipantIndexCheckedIn;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UILabel *lblParticipantIndexShow;

// Delegate methods
- (IBAction)onSwipeRight:(id)sender;
- (IBAction)onSwipeLeft:(id)sender;
- (IBAction)onParticipantIndexStepperChange:(id)sender;
- (IBAction)onCheckInToggleChange:(id)sender;

@end

