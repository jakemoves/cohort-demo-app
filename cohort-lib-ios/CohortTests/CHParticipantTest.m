//
//  CHParticipantTest.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-19.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CHParticipant.h"

@interface CHParticipantTest : XCTestCase

@end

@implementation CHParticipantTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testThatItInitsWithNilTags {
    NSError *error = nil;
    CHParticipant *participant = [[CHParticipant alloc] initWithTags:nil error:&error];
    
    if(error){
        NSLog(@"%@", error);
    }
    
    XCTAssertNotNil(participant);
    XCTAssertTrue([participant.tags containsObject:@"all"]);
    XCTAssertTrue(error.code == 1);
}

-(void)testThatItInitsWithNoTags {
    NSError *error = nil;
    NSSet *tags = [[NSSet alloc] init];
    CHParticipant *participant = [[CHParticipant alloc] initWithTags:tags error:&error];
    
    if(error){
        NSLog(@"%@", error);
    }
    
    XCTAssertNotNil(participant);
    XCTAssertTrue([participant.tags containsObject:@"all"]);
    XCTAssertTrue(error.code == 1);
}

-(void)testThatItInitsWithNilError {
    CHParticipant *participant = [[CHParticipant alloc] initWithTags:nil error:nil];
    XCTAssertNotNil(participant);
}

-(void)testThatItAddsAllTagIfMissing {
    NSError *error = nil;
    NSSet *tags = [NSSet setWithObjects:@"blue", nil];
    CHParticipant *participant = [[CHParticipant alloc] initWithTags:tags error:&error];
    
    if(error){
        NSLog(@"%@", error);
    }
    
    XCTAssertNotNil(participant);
    XCTAssertTrue([participant.tags containsObject:@"blue"]);
    XCTAssertTrue([participant.tags containsObject:@"all"]);
    XCTAssertTrue(error.code == 2);
}

@end
