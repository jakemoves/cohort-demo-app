//
//  CHEventTest.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-19.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CHEvent.h"

@interface CHEvent (Testing)

-(CHTrigger *)createTriggerFromJSON:(NSDictionary *)triggerJSON forCueNumber:(NSNumber *)cueNumber forMediaType:(CHMediaTypeString)mediaType error:(NSError **)error;

@end


@interface CHEventTest : XCTestCase

@end

@implementation CHEventTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatItInits {
    CHEvent *event = [[CHEvent alloc] init];
    XCTAssertNotNil(event);
}

- (void)testThatItInitsWithValidJSONShowbook {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event.json" andSession:session inBundle:bundle error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(event);
}

- (void)testThatItDoesNotInitWithNilShowbook {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:nil andSession:session inBundle:bundle error: &error];
    XCTAssertNotNil(error);
    XCTAssertNil(event);
    XCTAssert(error.code == 1);
}

- (void)testThatItDoesNotInitWithInvalidJSONShowbook {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event-invalidsyntax.json" andSession:session inBundle:bundle error: &error];
    XCTAssertNotNil(error);
    XCTAssertNil(event);
    XCTAssert(error.code == 2);
}

- (void)testThatItDoesNotInitWithNoEpisodeEntryInJSONShowbook {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event-noepisodes.json" andSession:session inBundle:bundle error: &error];
    XCTAssertNotNil(error);
    XCTAssertNil(event);
    XCTAssert(error.code == 4);
}

- (void)testThatItDoesNotInitWithMissingAsset {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event-noassetfile.json" andSession:session inBundle:bundle error: &error];
    XCTAssertNotNil(error);
    XCTAssertNil(event);
    XCTAssert(error.code == 3);
}

- (void)testThatItDoesNotInitWithInvalidTriggerType{
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event-badtriggertype.json" andSession:session inBundle:bundle error: &error];
    XCTAssertNotNil(error);
    XCTAssertNil(event);
    XCTAssert(error.code == 5);
}

- (void)testThatOneEpisodeLoads {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error;
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event.json" andSession:session inBundle:bundle error:&error];
    
    error = [event loadEpisodes];
    XCTAssertNil(error);
    XCTAssertNotNil(event);
}

- (void)testThatEpisodeDoesNotPlayWhenLoaded {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error;
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event.json" andSession:session inBundle:bundle error:&error];

    NSAssert(event, @"Event should not be nil");
    error = [event loadEpisodes];
    NSAssert(!error, @"Error loading episodes");
    for(NSString *key in event.episodes){
        CHEpisode *episode = event.episodes[key];
        NSLog(@"%@", episode.episodeId);
        NSAssert(!episode.isRunning, @"Episode should not start running on load");
    }
}

- (void)testThatMoreThanOneEpisodeLoads {
    CHSession *session = [[CHSession alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *error;
    CHEvent *event = [[CHEvent alloc] initWithJSONShowbook:@"test-event-twoepisodes.json" andSession:session inBundle:bundle error:&error];
    
    error = [event loadEpisodes];
    XCTAssertNil(error);
    XCTAssertNotNil(event);
}

// INTERNAL METHOD TESTS

- (void)testThatItCanCreateTimedTriggersForSoundCues {
    NSDictionary *triggerJSON = @{@"type":@"timed", @"time":@1};
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] init];
    CHTrigger *trigger = [event createTriggerFromJSON:triggerJSON forCueNumber:[NSNumber numberWithInt:1]forMediaType:CHMediaTypeStringSound error:&error];
    XCTAssertNotNil(trigger);
    XCTAssertNil(error);
}

- (void)testThatItCanCreateCalledTriggersForSoundCues {
    NSDictionary *triggerJSON = @{@"type":@"called"};
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] init];
    CHTrigger *trigger = [event createTriggerFromJSON:triggerJSON forCueNumber:[NSNumber numberWithInt:1] forMediaType:CHMediaTypeStringSound error:&error];
    XCTAssertNotNil(trigger);
    XCTAssertNil(error);
}

- (void)testThatItCanCreateTimedTriggersForEpisodes {
    NSDictionary *triggerJSON = @{@"type":@"timed", @"time":@1};
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] init];
    CHTrigger *trigger = [event createTriggerFromJSON:triggerJSON forCueNumber:[NSNumber numberWithInt:1] forMediaType:CHMediaTypeStringEpisode error:&error];
    XCTAssertNotNil(trigger);
    XCTAssertNil(error);
}

- (void)testThatItCanCreateCalledTriggersForEpisodes {
    NSDictionary *triggerJSON = @{@"type":@"called"};
    NSError *error = nil;
    
    CHEvent *event = [[CHEvent alloc] init];
    CHTrigger *trigger = [event createTriggerFromJSON:triggerJSON forCueNumber:[NSNumber numberWithInt:1] forMediaType:CHMediaTypeStringEpisode error:&error];
    XCTAssertNotNil(trigger);
    XCTAssertNil(error);
}

@end
