//
//  CHSoundAssetTest.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-09.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CHSoundAsset.h"

@interface CHSoundAssetTest : XCTestCase

@property (nonatomic, strong) XCTestExpectation *tempExpectation;

@end

@implementation CHSoundAssetTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatItInits {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrack.m4a" error:&error];
    XCTAssertNotNil(asset);
    XCTAssertTrue(asset.mediaType == CHMediaTypeSound);
    XCTAssertTrue([asset.assetId isEqualToString:@"clicktrack"]);
}

- (void)testThatItThrowsErrorOnEmptyAssetId {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"" inBundle:bundle andFilename:@"clicktrack.m4a" error:&error];
    XCTAssertNil(asset);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 2);
}

- (void)testThatItThrowsErrorOnNilAssetId {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:nil inBundle:bundle andFilename:@"clicktrack.m4a" error:&error];
    XCTAssertNil(asset);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 1);
}

- (void)testThatItThrowsErrorOnNonexistentFile {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:@"clicktrack" inBundle:bundle andFilename:@"clicktrak.m4a" error:&error];
    XCTAssertNil(asset);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 3);
}

@end
