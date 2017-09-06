//
//  ViewController.m
//  CohortClient
//
//  Created by Jacob Niedzwiecki on 2015-12-13.
//  Copyright © 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _flags = [[NSMutableDictionary alloc] init];
    [_flags setObject:[NSNumber numberWithBool:NO] forKey:@"userWasRemindedTheyNeedInternetAccess"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remindUserToConnectToInternet:) name:@"internet not available" object:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.mainViewController = self;
    
}

// this should be in CHEvent!
- (void)checkParticipantIn:(NSNumber *)participantIndex {
    
    if(!_session){
        [self createSession];
    }
    
    NSError *error;
    _session.participant = [[CHParticipant alloc] initWithTags:[NSSet setWithObjects:@"all", participantIndex, nil] error:&error];
    _session.participantIndex = participantIndex;
    
    [self createEvent];
    
    
    // start bg audio
    CHTrigger *bgAudioTrigger = [[CHTrigger alloc] initWithValue:0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&error];
    CHSoundAsset *bgAudioAsset = [[CHSoundAsset alloc] initWithAssetId:@"bg-audio" inBundle:[NSBundle mainBundle] andFilename:@"vinyl-bg-noise.m4a" error:&error];
    _bgAudioCue = [[CHSoundCue alloc] initWithSession:_session andAsset:bgAudioAsset withTriggers:[NSArray arrayWithObject:bgAudioTrigger] withTags:[NSSet setWithObject:@"all"] error:&error withCompletionBlock:^(){}];
    [_bgAudioCue load:&error];
    _bgAudioCue.audio.loop = true;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sound-0-go" object:nil];

    NSString *participantIndexString = [NSString stringWithFormat:@"%02d", [participantIndex intValue]];
     
    NSAttributedString *styledParticipantString =[[NSAttributedString alloc] initWithString:participantIndexString attributes:@{ NSExpansionAttributeName : @(-0.2f)}];

    _lblParticipantIndexCheckedIn.attributedText = styledParticipantString;
    _lblParticipantIndexShow.attributedText = styledParticipantString;
    
    __block NSError *sseError = nil;
    
    /*
        REPLACE URL BELOW WITH YOUR OWN SERVER INSTANCE - it's easy, check https://github.com/jakemoves/cohort-server
    */
     
    [_session listenForCuesWithURL:[NSURL URLWithString:@"http://cohortserver.herokuapp.com/listen"] withCompletionHandler:^(BOOL success, NSError *error) {
        if(!success){
            sseError = error;
            #ifdef DEBUG
            NSLog(@"%@", error);
            #endif
        }
    }];
    
    [_event.episodes[@"Queueing"] prepareCuesForParticipant:_session.participant error:&error];
    if(error){
        #ifdef DEBUG
        NSLog(@"%@", error);
        #endif
    }
}

- (void)checkParticipantOut {
    _session = nil;
    _event = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[appDelegate cohortSession] endSession];
    
    _showView.hidden = true;
    _scrollView.hidden = false;
}

- (void)createSession {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _session = [appDelegate cohortSession];
}

- (void)createEvent {
    NSError *eventError;
    _event = [[CHEvent alloc] initWithJSONShowbook:@"sample-showbook.json" andSession:_session inBundle:[NSBundle mainBundle] error:&eventError];
    if(_event){
        [_event loadEpisodes];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEpisodeStart:) name:@"firing episode" object:nil];
    } else {
    #ifdef DEBUG
        NSLog(@"%@", eventError);
    #endif
    }
}

- (void)onEpisodeStart:(NSNotification *)notification {
    _checkedInView.hidden = true;
    _showView.hidden = false;
}

- (void)remindUserToConnectToInternet:(NSNotification *) notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold up..." message:@"You'll need to be connected to the internet." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
    _flags[@"userWasRemindedTheyNeedInternetAccess"] = @YES;
}

// DELEGATE METHODS

// UIGestureRecognizerDelegate

- (IBAction)onSwipeRight:(id)sender {
    NSLog(@"swipe right");
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.5
                     animations:^(){
                         _checkInView.alpha = 1.0;
                         _checkInViewLeading.constant = 0;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished){
    }];
}

- (IBAction)onSwipeLeft:(id)sender {
    [self hideOptionsView];
}

- (IBAction)onPanFromRight:(UIScreenEdgePanGestureRecognizer *)sender{

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)onParticipantIndexStepperChange:(id)sender {
        NSNumber *tempParticipantIndex = [NSNumber numberWithDouble:_stepperParticipantIndex.value];
        _lblParticipantIndexCheckIn.text = [NSString stringWithFormat:@"%d", [tempParticipantIndex intValue]];
}

- (void)testLabelChange {
}

- (IBAction)onCheckInToggleChange:(id)sender {
    [self hideOptionsView];
    if(_checkInToggle.on){
        _scrollView.hidden = true;
        _checkedInView.hidden = false;
        [self checkParticipantIn:[NSNumber numberWithDouble:_stepperParticipantIndex.value]];
    } else {
        _checkedInView.hidden = true;
        _showView.hidden = true;
        _scrollView.hidden = false;
        [self checkParticipantOut];
    }
}

// UI METHODS

- (void)hideOptionsView {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:0.5
                     animations:^(){
                         _checkInView.alpha = 0.0;
                         _checkInViewLeading.constant = -_checkInView.frame.size.width;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished){
                         
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
