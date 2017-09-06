//
//  CHEpisodeTest.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-14.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CHEpisode.h"
#import "CHSoundCue.h"
@interface CHEpisodeTest : XCTestCase

@end

@implementation CHEpisodeTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatItDoesNotInitWithNilCueset {
    NSError *error = nil;
    NSError *secondaryError = nil;
    CHSession *session = [[CHSession alloc] init];
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSArray *triggers = [NSArray arrayWithObject:trigger];
    CHVoidBlock voidBlock;
    
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:nil withTriggers:triggers withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"%@", error);
    }
    XCTAssertNil(episode);
    XCTAssertTrue(error.code == 1);
}

- (void)testThatItDoesNotInitWithSetOfZeroCues {
    NSError *error = nil;
    NSError *secondaryError = nil;
    CHSession *session = [[CHSession alloc] init];
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSArray *triggers = [NSArray arrayWithObject:trigger];
    CHVoidBlock voidBlock;
    
    NSSet *tempCueset = [[NSSet alloc] init];
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:triggers withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"%@", error);
    }
    XCTAssertNil(episode);
    XCTAssertTrue(error.code == 2);
}

- (void)testThatItDoesNotInitWithNilEpisodeId {
    NSError *error = nil;
    NSError *secondaryError = nil;
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:nil error:&secondaryError withCompletionBlock:voidBlock];
    
    NSArray *triggers = [NSArray arrayWithObject:trigger];

    NSSet *tempCueset = [NSSet setWithObjects:cue, nil];
    CHEpisode *episode = [[CHEpisode alloc] initWithId:nil withSession:(CHSession *)session andCues:tempCueset withTriggers:triggers withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    XCTAssertNil(episode);
    XCTAssertTrue(error.code == 4);
}

- (void)testThatItDoesNotInitWithEmptyEpisodeId {
    NSError *error = nil;
    NSError *secondaryError = nil;
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:nil error:&secondaryError withCompletionBlock:voidBlock];
    
    NSArray *triggers = [NSArray arrayWithObject:trigger];
    
    NSSet *tempCueset = [NSSet setWithObjects:cue, nil];
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"" withSession:(CHSession *)session andCues:tempCueset withTriggers:triggers withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    XCTAssertNil(episode);
    XCTAssertTrue(error.code == 5);
}

- (void)testThatItDoesNotInitWithNilSession {
    NSError *error = nil;
    NSError *secondaryError = nil;
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:nil error:&secondaryError withCompletionBlock:voidBlock];
    
    NSArray *triggers = [NSArray arrayWithObject:trigger];
    
    NSSet *tempCueset = [NSSet setWithObjects:cue, nil];
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"episode-1" withSession:nil andCues:tempCueset withTriggers:triggers withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    XCTAssertNil(episode);
    XCTAssertTrue(error.code == 6);
}

-(void)testThatItInitsAndPrepsWithOneValidCue {
    NSError *error = nil;
    NSError *secondaryError = nil;
    NSSet *tags = [NSSet setWithObject:@"all"];
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
    
    CHTrigger *episodeTrigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&secondaryError];
    
    NSSet *tempCueset = [NSSet setWithObjects:cue, nil];
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    XCTAssertNotNil(episode);
    XCTAssertEqual(session, episode.session);
    XCTAssertNotNil(episode.cues);
    XCTAssertTrue(episode.cues.count == 1);
    
    session.participant = [[CHParticipant alloc] initWithTags:nil error:&secondaryError];
    [episode prepareCuesForParticipant:session.participant error:&error];
    
    for(id<NSObject, CHCueable> cue in episode.cues){
        if([cue conformsToProtocol:@protocol(CHCueable)]){
            XCTAssertTrue(cue.isLoaded);
        }
    }
    XCTAssertTrue(episode.cuesArePreparedForParticipant);
}


 -(void)testThatItInitsAndPrepsWithSeveralValidCues {
     NSError *error = nil;
     NSError *secondaryError = nil;
     NSSet *tags = [NSSet setWithObject:@"all"];
     CHSession *session = [[CHSession alloc] init];
     
     CHVoidBlock voidBlock;
     CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
     NSBundle *bundle = [NSBundle bundleForClass:[self class]];
     CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&error];
     CHSoundCue *cue1 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
     CHSoundCue *cue2 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
     CHSoundCue *cue3 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
     
     CHTrigger *episodeTrigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&secondaryError];
     
     NSSet *tempCueset = [NSSet setWithObjects:cue1,cue2,cue3, nil];
     CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:voidBlock error:&error];
     if(error){
         NSLog(@"Error: %@", error);
     }
     XCTAssertNotNil(episode);
     XCTAssertEqual(session, episode.session);
     XCTAssertNotNil(episode.cues);
     XCTAssertTrue(episode.cues.count == 3);
     
     session.participant = [[CHParticipant alloc] initWithTags:nil error:&secondaryError];
     [episode prepareCuesForParticipant:session.participant error:&error];
     
     if(error){
         NSLog(@"Error: %@", error);
     }
     
     for(id<NSObject, CHCueable> cue in episode.cues){
         if([cue conformsToProtocol:@protocol(CHCueable)]){
             XCTAssertTrue(cue.isLoaded);
         }
     }
     XCTAssertTrue(episode.cuesArePreparedForParticipant);
}

-(void)testThatItReturnsErrorOnInitWithCueArrayContainingNonCueObjects {
    NSError *error = nil;
    NSError *secondaryError = nil;
    NSSet *tags = [NSSet setWithObject:@"all"];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue1 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
    NSObject *cue2 = [[NSObject alloc] init];
    CHSoundCue *cue3 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
    
    CHTrigger *episodeTrigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&secondaryError];
    
    NSSet *tempCueset = [NSSet setWithObjects:cue1, cue2, cue3, nil];
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    XCTAssertNotNil(episode);
    XCTAssertTrue(error.code == 3);
}

-(void)testThatItReturnsCuesOfMediaType {
    NSError *error = nil;
    NSError *secondaryError = nil;
    NSSet *tags = [NSSet setWithObject:@"all"];
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue1 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
    CHSoundCue *cue2 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
    CHSoundCue *cue3 = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:voidBlock];
    
    CHTrigger *episodeTrigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&secondaryError];
    
    NSSet *tempCueset = [NSSet setWithObjects:cue1,cue2,cue3, nil];
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    
    NSSet *soundCues = [episode cuesOfMediaType:CHMediaTypeSound];
    XCTAssertTrue([soundCues isEqualToSet:tempCueset]);
}

-(void)testThatItStartsWithOneTimedCueOfTimeZeroWithMatchingTag {
    __weak XCTestExpectation *expectation = [self expectationForNotification:@"sound cue finished playing" object:nil handler:nil];
    //http://stackoverflow.com/questions/27555499/xctestexpectation-how-to-avoid-calling-the-fulfill-method-after-the-wait-contex
    
    NSError *error = nil;
    NSError *secondaryError = nil;
    NSSet *tags = [NSSet setWithObject:@"all"];
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:0.0 ofType:CHTriggeredAtTime forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:^void{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sound cue finished playing" object:nil];
    }];
    
    NSSet *tempCueset = [NSSet setWithObjects:cue, nil];
    
    CHTrigger *episodeTrigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&secondaryError];
    
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    XCTAssertNotNil(episode);
    XCTAssertEqual(session, episode.session);
    XCTAssertNotNil(episode.cues);
    XCTAssertTrue(episode.cues.count == 1);
    
    session.participant = [[CHParticipant alloc] initWithTags:nil error:&secondaryError];
    [episode prepareCuesForParticipant:session.participant error:&error];
    [episode fire];
    XCTAssertTrue(episode.isRunning);
    NSSet *runningCues = [episode cuesCurrentlyRunning];
    XCTAssertTrue(runningCues.count == 1);
    
    NSTimeInterval timeTilEndOfCue = cue.audio.duration + 3.0;
    
    [self waitForExpectationsWithTimeout:timeTilEndOfCue handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testThatItDoesNotPlayTimedCueOfTimeZeroWithNoMatchingTag {
    NSError *error = nil;
    NSError *secondaryError = nil;
    NSSet *tags = [NSSet setWithObject:@"blue"];
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:0.0 ofType:CHTriggeredAtTime forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:^void{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sound cue finished playing" object:nil];
    }];
    
    NSSet *tempCueset = [NSSet setWithObjects:cue, nil];
    
    CHTrigger *episodeTrigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&secondaryError];
    
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    XCTAssertNotNil(episode);
    XCTAssertEqual(session, episode.session);
    XCTAssertNotNil(episode.cues);
    XCTAssertTrue(episode.cues.count == 1);
    
    session.participant = [[CHParticipant alloc] initWithTags:nil error:&secondaryError];
    [episode prepareCuesForParticipant:session.participant error:&error];
    [episode fire];
    XCTAssertTrue(episode.isRunning);
    NSSet *runningCues = [episode cuesCurrentlyRunning];
    XCTAssertTrue(runningCues.count == 0);
}

-(void)testThatItStartsWithOneTimedCueOfTimeZeroViaNotification {
    __weak XCTestExpectation *expectation = [self expectationForNotification:@"sound cue finished playing" object:nil handler:nil];
    
    NSError *error = nil;
    NSError *secondaryError = nil;
    NSSet *tags = [NSSet setWithObject:@"all"];
    CHSession *session = [[CHSession alloc] init];
    
    CHVoidBlock voidBlock;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:0.0 ofType:CHTriggeredAtTime forMediaType:CHMediaTypeStringSound error:&secondaryError];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&secondaryError];
    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&secondaryError withCompletionBlock:^void{
        [expectation fulfill];
    }];
    
    NSSet *tempCueset = [NSSet setWithObject:cue];
    
    CHTrigger *episodeTrigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&secondaryError];
    
    CHEpisode *episode = [[CHEpisode alloc] initWithId:@"testEpisode" withSession:(CHSession *)session andCues:tempCueset withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:voidBlock error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    NSLog(@"created episode");
    
    session.participant = [[CHParticipant alloc] initWithTags:[NSSet setWithObject:@"all"] error:&secondaryError];
    [episode prepareCuesForParticipant:session.participant error:&error];
    if(error){
        NSLog(@"Error: %@", error);
    }
    [episode load:&error];if(error){
        NSLog(@"Error: %@", error);
    } else {
        NSLog(@"loaded episode");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"episode-1-go" object:nil];
    
    NSTimeInterval timeTilEndOfCue = 65;
    
    [self waitForExpectationsWithTimeout:timeTilEndOfCue handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

// test that loadWithAccessibleAlternative is used if participant has accessibility flags set
// test that prepareCuesForParticipant throws error if participant or triggers are nil/zero

@end
