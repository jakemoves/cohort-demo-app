//
//  CHSession.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-10.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"
#import "TheAmazingAudioEngine.h"
#import "EventSource.h"
#import "CHTypes.h"
#import "CHParticipant.h"

@interface CHSession : NSObject

@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) AEAudioController *audioController;
@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (strong, nonatomic) AEBlockScheduler *scheduler;
@property (strong, nonatomic) EventSource *sseClient;
@property (strong, nonatomic) NSMutableArray *channelGroups;
@property (strong, nonatomic) CHParticipant *participant;
@property (nonatomic) BOOL episodeIsPlaying;
@property (nonatomic) BOOL didNotifyUserAboutSSEError;
@property (strong, nonatomic) NSNumber *participantIndex;

- (void)listenForCuesWithURL:(NSURL *)url withCompletionHandler:(void (^)(BOOL success, NSError *error))handler;
- (void)endSession;

@end
