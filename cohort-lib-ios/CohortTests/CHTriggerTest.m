//
//  CHTriggerTest.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-19.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CHTrigger.h"

@interface CHTriggerTest : XCTestCase

@end

@implementation CHTriggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testThatItInits {
    NSError *error = nil;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredAtTime forMediaType:CHMediaTypeStringSound error:&error];
    XCTAssertNotNil(trigger);
    XCTAssertNil(error);
    XCTAssertTrue([trigger.value floatValue] == 1.0);
    XCTAssertTrue(trigger.type == CHTriggeredAtTime);
}

-(void)testThatItDoesNotInitWithNegativeValue {
    NSError *error = nil;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:-1.0 ofType:CHTriggeredAtTime forMediaType:CHMediaTypeStringSound error:&error];
    XCTAssertNil(trigger);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 2);
}

-(void)testThatItDoesNotInitWithUnknownType {
    NSError *error = nil;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:0 forMediaType:CHMediaTypeStringSound error:&error];
    XCTAssertNil(trigger);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 1);
}

-(void)testThatItDoesNotInitWithEmptyMediaType {
    NSError *error = nil;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredAtTime forMediaType:@"" error:&error];
    XCTAssertNil(trigger);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 4);
}

-(void)testThatItDoesNotInitWithNilMediaType {
    NSError *error = nil;
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredAtTime forMediaType:nil error:&error];
    XCTAssertNil(trigger);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 3);
}

-(void)testThatTimedTriggerArmsAndPulls {
    NSError *error = nil;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Trigger has been pulled"];
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.0 ofType:CHTriggeredAtTime forMediaType:CHMediaTypeStringSound error:&error];
    [trigger arm:^{
        [expectation fulfill];
    }];
    [trigger pull];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

-(void)testThatOtherTriggersArmAndPullWithNotificationWithIntValueForCuesOfSoundMediaType {
    NSError *error = nil;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Trigger has been pulled"];
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&error];
    [trigger arm:^{
        [expectation fulfill];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sound-1-go" object:nil];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testThatOtherTriggersArmAndPullWithNotificationWithFloatValueForCuesOfSoundMediaType {
    NSError *error = nil;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Trigger has been pulled"];
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.5 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringSound error:&error];
    [trigger arm:^{
        [expectation fulfill];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sound-1.5-go" object:nil];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testThatOtherTriggersArmAndPullWithNotificationWithIntValueForCuesOfEpisodeMediaType {
    NSError *error = nil;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Trigger has been pulled"];
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&error];
    [trigger arm:^{
        [expectation fulfill];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"episode-1-go" object:nil];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testThatOtherTriggersArmAndPullWithNotificationWithFloatValueForCuesOfEpisodeMediaType {
    NSError *error = nil;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Trigger has been pulled"];
    CHTrigger *trigger = [[CHTrigger alloc] initWithValue:1.5 ofType:CHTriggeredByServerSentEvent forMediaType:CHMediaTypeStringEpisode error:&error];
    [trigger arm:^{
        [expectation fulfill];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"episode-1.5-go" object:nil];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


@end
