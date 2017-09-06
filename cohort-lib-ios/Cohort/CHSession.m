//
//  CHSession.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-10.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "CHSession.h"

@implementation CHSession

- (id)init {
    if (self = [super init]) {
        // custom initialization
        
        _participant = nil;
        _participantIndex = [[NSNumber alloc] init];
        _episodeIsPlaying = false;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setEpisodeIsPlayingOn) name:@"episode started" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setEpisodeIsPlayingOff) name:@"episode stopped" object:nil];
        
        
        // audio functionality
        _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]];
        _audioController.preferredBufferDuration = 0.005;
        _audioController.useMeasurementMode = YES;
        [_audioController start:NULL];
        _channelGroups = [[NSMutableArray alloc] init];
        
        
        // video functionality
        _videoController = [[MPMoviePlayerController alloc] init];
        _videoController.fullscreen = false;
        _videoController.allowsAirPlay = false;
        _videoController.controlStyle = MPMovieControlStyleNone;
        _videoController.shouldAutoplay = false;
        _view = [[UIView alloc] init];
        
        
        // scheduling / cue timing
        _scheduler = [[AEBlockScheduler alloc] initWithAudioController:_audioController];
        [_audioController addTimingReceiver:_scheduler];
        
        // local notifications
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil]; // maybe should not live in library
        if([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
            //iOS 8+
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings]; // maybe should not live in library
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
        }
        _didNotifyUserAboutSSEError = false;
        
        // networking
        _sseClient = nil;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"internet available" object:nil];
#ifdef DEBUG
                    NSLog(@"internet available");
#endif
                    //available
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"internet not available" object:nil];
#ifdef DEBUG
                    NSLog(@"internet not available");
#endif
                    //not available
                    break;
                default:
                    break;
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    
    return self;
}

- (void)listenForCuesWithURL:(NSURL *)url
       withCompletionHandler:(void (^)(BOOL success, NSError *error))handler {
   
    _sseClient = [EventSource eventSourceWithURL:url];
    
    [_sseClient onOpen:^(Event *event) {
#ifdef DEBUG
        NSLog(@"SSE: onOpen, %@", event);
#endif
        _didNotifyUserAboutSSEError = false;
        handler(true, nil);
    }];
    
    [_sseClient onError:^(Event *event) {
#ifdef DEBUG
        NSLog(@"SSE: onError, %@", event);
#endif  
        if(!_didNotifyUserAboutSSEError){
            // should actually be based on 'is user checked in'
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.alertBody = @"There seems to be an issue connecting to the FluxDelux server. Please see one of our volunteers for assistance.";
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            _didNotifyUserAboutSSEError = true;
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"There seems to be an issue connecting to the FluxDelux server. Please see one of our volunteers for assistance." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SSE-error" object:nil];
            
            [alert show];
        }
        
        handler(false, event.error);
    }];
    
    __weak id weakSelf = self;
    [_sseClient addEventListener:@"cohortMessage" handler:^(Event *event) {
#ifdef DEBUG
        NSLog(@"SSE: %@, %@", event.event, event.data);
#endif
        NSError *error = nil;
        
        NSDictionary *sseEventData = [NSJSONSerialization JSONObjectWithData:[event.data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        if(!error){
            if([sseEventData objectForKey:@"action"]){
                NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:[AEBlockScheduler now]], @"receivedAt", nil];
                // this should all be handled in CHEvent, sigh
                NSString *action = [sseEventData objectForKey:@"action"];
                NSArray *actionComponents = [action componentsSeparatedByString:@"-"];
                
                //NSLog(@"action to 7: %@", action);
                if([[actionComponents objectAtIndex:0] isEqualToString:@"episode"]){
                    if([weakSelf episodeIsPlaying] == false){
                        // if nothing's running, start the episode
                        if([[actionComponents objectAtIndex:2] isEqualToString:CHTriggerActionTypeGo]){
                            [[NSNotificationCenter defaultCenter] postNotificationName:[sseEventData objectForKey:@"action"] object:nil userInfo:userInfo];
                        }
                    }
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:[sseEventData objectForKey:@"action"] object:nil userInfo:userInfo];
                }
            }
        } else {
            // TODO add error handling
        }
    }];
}

-(void)setEpisodeIsPlayingOn {
    _episodeIsPlaying = true;
#ifdef DEBUG
    NSLog(@"set episodeIsPlaying to %hhd", _episodeIsPlaying);
#endif
}

-(void)setEpisodeIsPlayingOff {
    _episodeIsPlaying = false;
#ifdef DEBUG
    NSLog(@"set episodeIsPlaying to %hhd", _episodeIsPlaying);
#endif
}

- (void)endSession {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_sseClient close];
    _scheduler = nil;
    
    NSArray *channels = [_audioController channels];
    for(int i = 0; i < channels.count; i++){
        AEAudioFilePlayer *audio = [channels objectAtIndex:i];
        audio.channelIsPlaying = false;
        [_audioController removeChannels:[NSArray arrayWithObject:audio]];
        audio = nil;
    }
    [_audioController stop];
    _audioController = nil;
}

- (void)dealloc{
    [self endSession];
}

@end
