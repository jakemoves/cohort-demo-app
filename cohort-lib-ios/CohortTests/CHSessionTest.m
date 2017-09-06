//
//  CHSessionTest.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-10.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AFNetworking.h"
#import "CHSession.h"

@interface CHSessionTest : XCTestCase

@end

@implementation CHSessionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatItInits {
    CHSession *session = [[CHSession alloc] init];
    XCTAssertNotNil(session, @"Session is nil");
    XCTAssertNotNil(session.audioController, @"Session audioController is nil");
    session = nil;
}

- (void)testThatItReportsReachability {
    __weak XCTestExpectation *expectation = [self expectationForNotification:@"internet available" object:nil handler:nil];
    CHSession *session = [[CHSession alloc] init];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    session = nil;
}

- (void)testThatItConnectsToSSEServer {
    // server must be running to pass
    CHSession *session = [[CHSession alloc] init];
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Connected to SSE server"];
    //http://stackoverflow.com/questions/27555499/xctestexpectation-how-to-avoid-calling-the-fulfill-method-after-the-wait-contex
    
    [session listenForCuesWithURL:[[NSURL alloc] initWithString:@"http://jqrs.org/test/listen"]
            withCompletionHandler:^(BOOL success, NSError *error) {
        if(success){
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    session = nil;
}

- (void)testThatItReportsBadHostName {
    CHSession *session = [[CHSession alloc] init];
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Could not connect to SSE server"];
    
    [session listenForCuesWithURL:[[NSURL alloc] initWithString:@"http://totallyinvalidURLthatdoesntexist.cz"]
            withCompletionHandler:^(BOOL success, NSError *error) {
                if(!success){
                    if((error.code) == -1003){
                        [expectation fulfill];
                    }
                }
            }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    session = nil;
}

- (void)testThatItReceivesAndProcessesSSE {
    // server must be running to pass
    __block CHSession *session = [[CHSession alloc] init];
    __weak XCTestExpectation *expectation = [self expectationForNotification:@"sound-1-go" object:nil handler:nil];
    //http://stackoverflow.com/questions/27555499/xctestexpectation-how-to-avoid-calling-the-fulfill-method-after-the-wait-contex

    [session listenForCuesWithURL:[[NSURL alloc] initWithString:@"http://cohort-server.herokuapp.com/listen"]
            withCompletionHandler:^(BOOL success, NSError *error) {
                if(success){
                    NSURL *baseURL = [NSURL URLWithString:@"http://cohort-server.herokuapp.com/"];
                    NSDictionary *body = @{@"action": @"sound-1-go"};
                    
                    AFHTTPRequestOperationManager *afManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
                    
                    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
                    [afManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    
                    [afManager POST:@"broadcast" parameters:body
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"POST request to cohort server succeeded");
                                XCTAssertTrue(true);
                                session = nil;
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                XCTFail(@"POST request to cohort server failed");
                                session = nil;
                    }];
                }
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            session = nil;
        }
    }];
}

//- (void)DISABLEDtestThatItReportsWhenServerNotRunning {
//    // server should not be running to pass
//    CHSession *session = [[CHSession alloc] init];
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Could not connect to SSE server"];
//    
//    [session listenForCuesWithURL:[[NSURL alloc] initWithString:@"http://jqrs.org/test/"]
//            withCompletionHandler:^(BOOL success, NSError *error) {
//                if(!success){
//                    NSLog(@"SSE: error %@", error);
//                    if((error.code) == 2){
//                        [expectation fulfill];
//                    }
//                }
//            }];
//    
//    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
//        if (error) {
//            NSLog(@"Timeout Error: %@", error);
//        }
//    }];
//}
//
//- (void)MANUALtestThatItClosesSSEConnectionWhenDeallocated {
//    __block CHSession *session = [[CHSession alloc] init];
//    
//    [session listenForCuesWithURL:[[NSURL alloc] initWithString:@"http://169.254.135.25:8000/listen"]
//            withCompletionHandler:^(BOOL success, NSError *error) {
//                if(success){
//                    NSLog(@"connected!");
//                }
//            }
//     ];
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        NSLog(@"killing session");
//        session = nil;
//    });
//}

@end
