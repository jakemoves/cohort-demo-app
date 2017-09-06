//
//  CHVideoAssetTest.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-07-10.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CHVideoAsset.h"

@interface CHVideoAssetTest : XCTestCase

@end

@implementation CHVideoAssetTest

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
    CHVideoAsset *asset = [[CHVideoAsset alloc] initWithAssetId:@"testPattern" inBundle:bundle andFilename:@"testpattern-540.m4v" error:&error];
    XCTAssertNotNil(asset);
    XCTAssertTrue(asset.mediaType == CHMediaTypeVideo);
    XCTAssertTrue([asset.assetId isEqualToString:@"testPattern"]);
}

- (void)testThatItThrowsErrorOnEmptyAssetId {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHVideoAsset *asset = [[CHVideoAsset alloc] initWithAssetId:@"" inBundle:bundle andFilename:@"testpattern-540.m4v" error:&error];
    XCTAssertNil(asset);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 2);
}

- (void)testThatItThrowsErrorOnNilAssetId {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHVideoAsset *asset = [[CHVideoAsset alloc] initWithAssetId:nil inBundle:bundle andFilename:@"testpattern-540.m4v" error:&error];
    XCTAssertNil(asset);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 1);
}

- (void)testThatItThrowsErrorOnNonexistentFile {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CHVideoAsset *asset = [[CHVideoAsset alloc] initWithAssetId:@"testPattern" inBundle:bundle andFilename:@"testpattern.m4v" error:&error];
    XCTAssertNil(asset);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 3);
}

@end
