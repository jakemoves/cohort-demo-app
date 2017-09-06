//
//  CHVideoCue.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-07-10.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "CHVideoCue.h"

@implementation CHVideoCue

@synthesize targetTags = _targetTags;
@synthesize mediaType = _mediaType;
@synthesize mediaTypeAsString = _mediaTypeAsString;
@synthesize triggers = _triggers;
@synthesize isLoaded = _isLoaded;
@synthesize isRunning = _isRunning;
@synthesize duration = _duration;
@synthesize completionBlock = _completionBlock;

- (id)initWithSession:(CHSession *)session andAsset:(CHVideoAsset *)asset withTriggers:(NSArray *)triggers withTags:(NSSet *)tags error:(NSError **)error withCompletionBlock:(CHVoidBlock)completionBlock {
    if (self = [super init]) {
        // custom initialization
        
        _mediaType = CHMediaTypeVideo;
        _mediaTypeAsString = CHMediaTypeStringVideo;
        _isLoaded = false;
        _isRunning = false;
        _completionBlock = completionBlock;
        
        // warnings first
        if(tags){
            _targetTags = [NSSet setWithSet:tags];
        } else {
            _targetTags = [[NSSet alloc] init];
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Warning: created video cue with no target tags"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.VideoCue.ErrorDomain" code:3 userInfo:tempDic];
        }
        
        if(triggers){
            _triggers = triggers;
        } else {
            _triggers = [[NSArray alloc] init];
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Warning: video cue with no triggers will never play"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.VideoCue.ErrorDomain" code:4 userInfo:tempDic];
        }
        
        if(session){
            _session = session;
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create video cue because the session is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.VideoCue.ErrorDomain" code:1 userInfo:tempDic];
        }
        
        if(asset){
            _asset = asset;
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create video cue because the asset is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.VideoCue.ErrorDomain" code:2 userInfo:tempDic];
        }
        
        if(!_session || !_asset){
            self = nil;
        } else {
            // finish setup
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        }
    }

    return self;
}


// CHCueable ________________________

- (void)load:(NSError *__autoreleasing *)error {
    
    _session.videoController.contentURL = _asset.sourceFile;
    [_session.videoController prepareToPlay];
    
}


-(void) loadWithAccessibleAlternative:(NSError **)error {
    [self load:error];
}

- (void)fire {
    if(true){
        [self play];
    }
}

- (void)play {
    //[_video play];
}

- (void)pause {
    //[_video pause];
}

// end CHCueable_______________________

-(void)onLoadStateDidChange:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"load state changed: %@", notification);
#endif
    

//    if(_triggers && _triggers.count > 0){
//        for(CHTrigger *trigger in _triggers){
//            // arm the trigger
//            __weak id weakSelf = self;
//            [trigger arm:^{
//                [weakSelf fire];
//            }];
//        }
//    } else {
//        // TODO add error handling as per CHEpisode
//    }
}

@end
