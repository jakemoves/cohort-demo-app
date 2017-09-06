//
//  CHSoundCue.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-11.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "CHSoundCue.h"

@implementation CHSoundCue

@synthesize targetTags = _targetTags;
@synthesize mediaType = _mediaType;
@synthesize mediaTypeAsString = _mediaTypeAsString;
@synthesize triggers = _triggers;
@synthesize isLoaded = _isLoaded;
@synthesize isRunning = _isRunning;
@synthesize duration = _duration;
@synthesize completionBlock = _completionBlock;

- (id)initWithSession: (CHSession *)session andAsset:(CHSoundAsset *)asset withTriggers:(NSArray *)triggers withTags:(NSSet *)tags error:(NSError **)error withCompletionBlock:(CHVoidBlock)completionBlock {
    if (self = [super init]) {
        // custom initialization
        
        _mediaType = CHMediaTypeSound;
        _mediaTypeAsString = CHMediaTypeStringSound;
        _isLoaded = false;
        _isRunning = false;
        _completionBlock = completionBlock;
        _useAccessibleAlternative = false;
        _altText = nil;
        
        // warnings first
        if(tags){
            _targetTags = [NSSet setWithSet:tags];
        } else {
            _targetTags = [[NSSet alloc] init];
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Warning: created sound cue with no target tags"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.SoundCue.ErrorDomain" code:3 userInfo:tempDic];
        }
        
        if(triggers){
            _triggers = triggers;
        } else {
            _triggers = [[NSArray alloc] init];
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Warning: sound cue with no triggers will never play"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.SoundCue.ErrorDomain" code:4 userInfo:tempDic];
        }
        
        // then errors
        if(session){
            _session = session;
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create sound cue because the session is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.SoundCue.ErrorDomain" code:1 userInfo:tempDic];
        }
        
        if(asset){
            _asset = asset;
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create sound cue because the asset is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.SoundCue.ErrorDomain" code:2 userInfo:tempDic];
        }
        
        if(!_session || !_asset){
            self = nil;
        } else {
            // finish setup
        }
    }
    
    return self;
}


// CHCueable ________________________

- (void)load:(NSError **)error {
    //NSLog(@"loading cue");
    if(_session.channelGroups.count == 0){
        //NSLog(@"making first channel group");
        [self addChannelGroup];
    } else {
        //NSLog(@"checking how many channels in this group");
        AEChannelGroupRef currentGroup;
        [[_session.channelGroups objectAtIndex:_session.channelGroups.count-1] getValue:&currentGroup];
        NSArray *channelsInGroup =[_session.audioController channelsInChannelGroup:currentGroup];
        uint8_t channelCount = channelsInGroup.count;
        if(channelCount == 98 /*AEAudioController kMaximumChannelsPerGroup*/){
           // NSLog(@"at max channels, making new group");
            [self addChannelGroup];
        }
    }
    
    //NSLog(@"adding cue to channel group %i", (_session.channelGroups.count-1));
    
    AEChannelGroupRef currentGroup;
    [[_session.channelGroups objectAtIndex:_session.channelGroups.count-1] getValue:&currentGroup];
    NSError *secondaryError = nil;
    _audio = [[AEAudioFilePlayer alloc] initWithURL:_asset.sourceFile error:&secondaryError];
    if(!secondaryError){
        _audio.channelIsPlaying = false;
        _audio.loop = false;
    }
    [_session.audioController addChannels:[NSArray arrayWithObject:_audio]
                           toChannelGroup:currentGroup];
    
    //[_session.audioController addChannels:[NSArray arrayWithObject:_audio]];
    
    _duration = _audio.duration;
    
    if(_triggers && _triggers.count > 0){
        for(CHTrigger *trigger in _triggers){
            // arm the trigger
            __weak id weakSelf = self;
            [trigger arm:^{
                [weakSelf fire];
            }];
        }
    } else {
        // TODO add error handling as per CHEpisode
    }
    
    _isLoaded = true;
}

- (void)loadWithAccessibleAlternative:(NSError **)error {
    NSError *secondaryError = nil;
    if(_altText){
        _useAccessibleAlternative = true;
        [self load:&secondaryError];
    } else {
        NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not load accessible sound cue because sound cue has no alt text"};
        *error = [[NSError alloc] initWithDomain:@"rocks.cohort.SoundCue.ErrorDomain" code:5 userInfo:tempDic];
    }
}

- (void)fire {
    if(_completionBlock){
        _audio.completionBlock = _completionBlock;
    }
    
    [self play];
    
    if(_useAccessibleAlternative){
        // send notification with alt text
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = _altText;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        // works in background only — for foreground, add the following function to app delegate
        /*- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
            {
            // do stuff, i.e. show an alert and play a sound
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Notification Received" message:notification.alertBody delegate:nil 	cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
         }*/
    }
}

- (void)play {
    _isRunning = true;
    _audio.channelIsPlaying = true;
}

// not tested yet!
- (void)pause {
//    _isRunning = false;
//    _audio.channelIsPlaying = false;
}

    
// Other methods
    
-(void)addChannelGroup{
    //NSLog(@"making first channel group: 1");
    AEChannelGroupRef group =[_session.audioController createChannelGroup];
    //NSLog(@"making first channel group: 2");
    [_session.channelGroups addObject:[NSValue value:&group withObjCType:@encode(AEChannelGroupRef)]];
}

- (void)dealloc{
#ifdef DEBUG
    //NSLog(@"deallocating sound cue");
#endif
    
    _triggers = nil;
    
    //NSLog(@"   aa");
    
    if(_isRunning){
        [self pause];
    }
    //NSLog(@"   bb");
    
    if(_isLoaded){
        [_session.audioController removeChannels:[NSArray arrayWithObject:_audio]];
    }
    
    //NSLog(@"   cc");
}

@end
