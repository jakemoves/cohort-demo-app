//
//  CHEpisode.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-15.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "CHEpisode.h"

@implementation CHEpisode

@synthesize targetTags = _targetTags;
@synthesize mediaType = _mediaType;
@synthesize mediaTypeAsString = _mediaTypeAsString;
@synthesize triggers = _triggers;
@synthesize isLoaded = _isLoaded;
@synthesize isRunning = _isRunning;
@synthesize duration = _duration;
@synthesize completionBlock = _completionBlock;

- (id)initWithId:(NSString *)episodeId withSession:(CHSession *)session andCues:(NSSet *)cues withTriggers:(NSArray *)triggers withCompletionBlock:(CHVoidBlock)completionBlock error:(NSError **)error {
    if (self = [super init]) {
        // custom initialization
        
        NSMutableArray *tempCues = nil;
        
        _mediaType = CHMediaTypeEpisode;
        _mediaTypeAsString = CHMediaTypeStringEpisode;
        
        _isRunning = false;
        _isLoaded = false;
        _cuesArePreparedForParticipant = false;
        
        _completionBlock = completionBlock;
        
        if(episodeId){
            if([episodeId isEqualToString:@""]){
                NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create episode because the episodeId is an empty string"};
                *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:5 userInfo:tempDic];
            } else {
                _episodeId = episodeId;
            }
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create episode because the episodeId is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:4 userInfo:tempDic];
        }
        
        if(session){
            _session = session;
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create episode because the session is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:6 userInfo:tempDic];
        }
        
        if(cues){
            if(cues.count == 0){
                _cues = nil;
                
                NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create episode because the cueset is empty"};
                *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:2 userInfo:tempDic];
            } else {
                // create cues set
                for(id<NSObject, CHCueable> cue in cues){
                    if([cue conformsToProtocol:@protocol(CHCueable)]){
                        if(tempCues){
                            [tempCues addObject:cue];
                        } else {
                            tempCues = [[NSMutableArray alloc] initWithObjects:cue, nil];
                        }
                    } else {
                        NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not add cue to episode because the cue is not valid"};
                        *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:3 userInfo:tempDic];
                    }
                }
            }
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create episode because the cueset is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:1 userInfo:tempDic];
        }
        
        if(triggers){
            _triggers = triggers;
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Warning: episode with no triggers will never play"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:7 userInfo:tempDic];
        }
        
        if(tempCues) {
            _cues = [NSSet setWithArray:tempCues];
            tempCues = nil;
        }
        
        if(!_episodeId || !_session || !_cues){
            self = nil;
        }
    }
    
    return self;
}

-(void) prepareCuesForParticipant:(CHParticipant *)participant error:(NSError **)error {

    if(_session.participant){
        NSError *cueLoadError = nil;
        for(id<NSObject, CHCueable> cue in _cues){
            if([cue.targetTags intersectsSet:_session.participant.tags]){
                // check if participant has accessibility flags set for this cue type
                if([_session.participant.tags containsObject:cue.mediaTypeAsString]){
                    [cue loadWithAccessibleAlternative:&cueLoadError];
                } else {
                    [cue load:&cueLoadError];
                }
            }
        }
        if(cueLoadError){
            *error = cueLoadError;
        } else {
            _cuesArePreparedForParticipant = true;
        }
    } else {
        NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not load episode because the participant is nil"};
        *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:8 userInfo:tempDic];
        return;
    }
}

// CHCueable ________________________

-(void) load:(NSError **)error {
    
    if(_triggers && _triggers.count > 0){
        for(CHTrigger *trigger in _triggers){
            __weak id weakSelf = self;
            [trigger arm:^{
                [weakSelf fire];
            }];
        }
    } else {
        NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not load episode with no triggers"};
        *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:9 userInfo:tempDic];
    }
    _isLoaded = true;
}

-(void) fire {
    NSDictionary *tempDic = [[NSDictionary alloc] initWithObjectsAndKeys:_episodeId, @"episodeId", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"firing episode" object:nil userInfo:tempDic];
    if(_cuesArePreparedForParticipant){
        [self play];
    } else {
        // set safety delay for loading audio
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * _cues.count * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self play];
        });
        NSError *error = nil;
        [self prepareCuesForParticipant:_session.participant error:&error];
    }
    _isRunning = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"episode started" object:nil];
}

-(void) play {
    _startTime = [AEBlockScheduler now];
    double endingTimestamp = [AEBlockScheduler timestampWithSeconds:_duration fromTimestamp:_startTime];
    [self scheduleForExecutionAtTime:endingTimestamp withMainThreadBlock:^{
        [self stop];
    }];
    _isRunning = true;
    
    // this was a performance hack but may not be necessary anymore
    // get cues with timed triggers at 0 secs and start them playing ASAP
    NSSet *timedCues = [self cuesWithTriggersOfType:CHTriggeredAtTime];
    NSSet *immediateCues = [timedCues objectsPassingTest:^BOOL(id<CHCueable> obj, BOOL *stop) {
        if(obj.triggers.count > 0){
            for(CHTrigger *trigger in obj.triggers){
                if(((double)[trigger.value doubleValue] == 0.0) && ([obj.targetTags intersectsSet:_session.participant.tags])){
                    return YES;
                }
            }
            return NO;
        } else {
            return NO;
        }
    }];
    
    for(id<CHCueable> cue in immediateCues){
        // [cue.completionBlock = ^void{}];
        [cue fire];
    }
    // end hack
    
    // schedule all timed triggers
    for(id<CHCueable> cue in [self cuesWithTriggersOfType:CHTriggeredAtTime]){
        double timestamp;
        for(CHTrigger *trigger in cue.triggers){
            if(((double)[trigger.value doubleValue] != 0.0) && ([cue.targetTags intersectsSet:_session.participant.tags])){
                timestamp = [AEBlockScheduler timestampWithSeconds:[trigger.value longLongValue] fromTimestamp:_startTime];
                [self scheduleForExecutionAtTime:timestamp withMainThreadBlock:^{
                    [trigger pull];
                }];
            }
        }
    }
}

-(void) pause {
    
}

- (void) stop {
    // remove channels
//    for(int i = 0; i < _session.channelGroups.count; i++){
//        AEChannelGroupRef currentGroup;
//        [[_session.channelGroups objectAtIndex:i] getValue:&currentGroup];
//        NSArray *channels = [_session.audioController channelsInChannelGroup:currentGroup];
//   
//        for(int i = 0; i < channels.count; i++){
//            AEAudioFilePlayer *audio = [channels objectAtIndex:i];
//            if(audio.channelIsPlaying){
//                audio.channelIsPlaying = false;
//            }
//            [_session.audioController removeChannels:[NSArray arrayWithObject:audio]];
//        }
//    }
//    //NSLog(@"   a");
//    _cues = nil;
//   // NSLog(@"   b");
//    _triggers = nil;
//   // NSLog(@"   c");
//    
//    if(_isRunning){
//        [_session.scheduler cancelScheduleWithIdentifier:@"CHCue"];
//        _isRunning = false;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"episode stopped" object:nil];
//    }
}

// end CHCueable
// ______________________________________

- (NSSet *)cuesOfMediaType: (CHMediaType)mediaType {
    NSSet *cueSubset = [_cues objectsPassingTest:^BOOL(id<CHCueable> obj, BOOL *stop) {
        CHMediaType cueType = (CHMediaType)obj.mediaType;
        if(cueType == mediaType){
            return YES;
        } else {
            return NO;
        }
    }];
    return cueSubset;
}

- (NSSet *)cuesWithTriggersOfType: (CHTriggerType)triggerType {
    NSSet *cueSubset = [_cues objectsPassingTest:^BOOL(id<CHCueable> obj, BOOL *stop) {
        if(obj.triggers){
            if(obj.triggers.count > 0){
                for(CHTrigger *trigger in obj.triggers){
                    CHTriggerType cueType = (CHTriggerType)trigger.type;
                    if(cueType == triggerType){
                        return YES;
                    }
                }
                return NO;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    }];
    return cueSubset;
}

- (void)scheduleForExecutionAtTime:(uint64_t)timestamp
      withMainThreadBlock:(void (^)())cueBlock
 withCoreAudioThreadBlock:(void (^)())coreAudioBlock
{
    [_session.scheduler scheduleBlock:^(const AudioTimeStamp *time, UInt32 offset){
        // null block on core audio thread
        //NSLog(@"triggering UI cue (core audio thread)");
        coreAudioBlock();
    }
                                        atTime:timestamp
                                 timingContext:AEAudioTimingContextOutput
                                    identifier:@"CHCue"
                       mainThreadResponseBlock:^(const AudioTimeStamp *time, UInt32 offset) {
                           // We are now on the main thread at *time*, which is *offset* frames
                           // before the time we scheduled, *timestamp*.
                           cueBlock();
                       }
     ];
}

// convenience call when the coreAudio block is null (most cases)
- (void)scheduleForExecutionAtTime:(uint64_t)timestamp
      withMainThreadBlock:(void (^)())cueBlock
{
    [self scheduleForExecutionAtTime:timestamp withMainThreadBlock:cueBlock withCoreAudioThreadBlock:^(){}];
}

- (NSSet *)cuesCurrentlyRunning {
    NSSet *cueSubset = [_cues objectsPassingTest:^BOOL(id<CHCueable> obj, BOOL *stop) {
        if(obj.isRunning){
            return YES;
        } else {
            return NO;
        }
    }];
    return cueSubset;
}

-(void)dealloc{
    [self stop];
}

@end
