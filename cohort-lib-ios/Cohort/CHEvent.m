//
//  CHEvent.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-19.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "CHEvent.h"

@implementation CHEvent

-(id)initWithJSONShowbook:(NSString *)showbookFilename andSession:(CHSession *) session inBundle:(NSBundle *)bundle error:(NSError **)error {
    if (self = [super init]) {
        // custom initialization
        
        _session = session;
        
        // verify showbookFilename argument is not nil
        if(showbookFilename){
            NSString *assetPath = [bundle resourcePath];
            NSString *filepath = [assetPath stringByAppendingPathComponent:showbookFilename];
            
            // verify file exists
            if([[NSFileManager defaultManager] fileExistsAtPath: filepath] == NO)
            {
#ifdef DEBUG
                NSLog(@"Didn't find showbook file");
#endif
                NSDictionary *tempDic = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not create event because file '%@' does not exist at path ' %@", showbookFilename, filepath]};
                *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Asset.ErrorDomain" code:3 userInfo:tempDic];
            } else {
                NSData *data = [NSData dataWithContentsOfFile:filepath];
                NSError *jsonSerializationError = nil;
                
                NSDictionary *showbook = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonSerializationError];
                
                // verify JSON serialization succeeded
                if(!jsonSerializationError){
                    _showbook = showbook;
                    _name = [showbook objectForKey:@"event"];
                    
                    NSError *episodeParseError = nil;
                    _episodes = [self createEpisodesFromShowbookUsingBundle:bundle error:&episodeParseError];
                    if(episodeParseError){
                        //NSLog(@"%@", episodeParseError);
                        *error = episodeParseError;
                    }
                    
                } else {
                    NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create event because of an error in the JSON showbook"};
                    *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:2 userInfo:tempDic];
                }
            }
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create event because the showbook filename is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:1 userInfo:tempDic];
        }
        
        if(!_showbook || !_episodes){
            self = nil;
        }
    }
    
    return self;
}

-(NSError *)loadEpisodes {
    NSError *error = nil;
    for(NSString *key in _episodes){
        [_episodes[key] load:&error];
    }
    
    return error;
}


// INTERNAL METHODS

-(NSDictionary *)createEpisodesFromShowbookUsingBundle:(NSBundle *)bundle error:(NSError **)error{
    NSMutableDictionary *episodes;
    
    // verify showbook has episodes
    if(_showbook[@"episodes"]){
        
        NSError *assetError;
        NSError *triggerError;
        NSError *soundCueError;
        NSError *episodeError;
        NSError *episodeTriggerError;
        
        episodes = [[NSMutableDictionary alloc] init];
        
        for(NSDictionary *episode in _showbook[@"episodes"]){
            NSMutableArray *cues = [[NSMutableArray alloc] init];
            
            // do we need to verify episode has cues?
            for(NSDictionary *cueInfo in episode[@"cues"]){
                #ifdef DEBUG
                // NSLog(@"parsing cue %@", cueInfo[@"cueNumber"]);
                // NSLog(@"%@", cueInfo);
                #endif
                
                // ASSET
                CHSoundAsset *asset = [[CHSoundAsset alloc] initWithAssetId:[cueInfo[@"filename"] stringByDeletingPathExtension] inBundle:bundle andFilename:cueInfo [@"filename"] error:&assetError];
                if(assetError){
                    #ifdef DEBUG
                    NSLog(@"%@", assetError);
                    #endif
                    *error = assetError;
                }
                
                // TRIGGER
                CHTrigger *trigger = [self createTriggerFromJSON:cueInfo[@"cueTrigger"] forCueNumber:cueInfo[@"cueNumber"] forMediaType:CHMediaTypeStringSound error:&triggerError];
                
                if(triggerError){
                    #ifdef DEBUG
                    NSLog(@"%@", triggerError);
                    #endif
                    *error = triggerError;
                }
                
                // CUE
                if(!*error && asset && trigger){
                    NSArray *tagsInCue = cueInfo[@"targetTags"];
                    NSSet *tags = [NSSet setWithArray:tagsInCue];
                    
                    CHSoundCue *cue = [[CHSoundCue alloc] initWithSession:_session andAsset:asset withTriggers:[NSArray arrayWithObject:trigger] withTags:tags error:&soundCueError withCompletionBlock:^{
                        // on complete
                    }];
                    
                    if(!soundCueError){
                        cue.altText = cueInfo[@"accessibleDescription"];
                        [cues addObject:cue];
                    } else {
                        #ifdef DEBUG
                        NSLog(@"%@", soundCueError);
                        #endif
                        *error = soundCueError;
                    }
                } else {
                    NSLog(@"no asset or trigger?");
                }
            }
            
            if(!*error){
                // EPISODE TRIGGER
                CHTrigger *episodeTrigger = [self createTriggerFromJSON:episode[@"episodeTrigger"] forCueNumber:episode[@"episodeNumber"] forMediaType:CHMediaTypeStringEpisode error:&episodeTriggerError];
                
                if(episodeTriggerError){
                    #ifdef DEBUG
                    NSLog(@"%@", episodeTriggerError);
                    #endif
                    *error = episodeTriggerError;
                }
                
                NSSet *finalCues = [cues copy];
                
                CHEpisode *newEpisode = [[CHEpisode alloc] initWithId:episode[@"displayName"] withSession:_session andCues:finalCues withTriggers:[NSArray arrayWithObject:episodeTrigger] withCompletionBlock:^{
                    // on complete
                } error:&episodeError];
                
                if(!episodeError){
                    episodes[newEpisode.episodeId] = newEpisode;
                } else {
                    #ifdef DEBUG
                    NSLog(@"%@", soundCueError);
                    #endif
                    *error = episodeError;
                }
            }
        }
        
        if(*error){
            episodes = nil;
        }
    } else {
        NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create event because no 'episodes' entry exists in the JSON showbook"};
        *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Event.ErrorDomain" code:4 userInfo:tempDic];
    }
    
    return [episodes copy];
}

-(CHTrigger *)createTriggerFromJSON:(NSDictionary *)triggerJSON forCueNumber:(NSNumber *)cueNumber forMediaType:(CHMediaTypeString)mediaType error:(NSError **)error {
    
    CHTrigger *trigger;
    NSError *triggerError;
    
    NSString *triggerTypeString = triggerJSON[@"type"];
    
    CHTriggerType triggerType = CHTriggerTypeUnknown;
    
    // time for timed triggers, cue number for called triggers
    NSNumber *mainValue;
    
    // for canon cues
    NSNumber *canonDelay;
    
    if([triggerTypeString isEqualToString:@"timed"]){
        triggerType = CHTriggeredAtTime;
        mainValue = triggerJSON[@"time"];
    } else if([triggerTypeString isEqualToString:@"called"]){
        triggerType = CHTriggeredByServerSentEvent;
        mainValue = cueNumber;
    } else if([triggerTypeString isEqualToString:@"timedWithCanon"] || [triggerTypeString isEqualToString:@"calledWithCanon"]){
        if(triggerJSON[@"canonDelay"]){
            if([triggerTypeString isEqualToString:@"timedWithCanon"]){
                triggerType = CHTriggeredAtTimeWithCanon;
                mainValue = triggerJSON[@"time"];
                canonDelay = triggerJSON[@"canonDelay"];
            } else {
                triggerType = CHTriggeredByServerSentEventWithCanon;
                mainValue = cueNumber;
                canonDelay = triggerJSON[@"canonDelay"];
            }
        } else {
            NSString *errorDesc = [NSString stringWithFormat:@"Could not create cue %@ in event because there is no canon value in the JSON showbook", triggerJSON[@"cueNumber"]];
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: errorDesc};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Event.ErrorDomain" code:6 userInfo:tempDic];
            #ifdef DEBUG
            NSLog(@"%@", *error);
            #endif
        }
    } else {
        NSString *errorDesc = [NSString stringWithFormat:@"Could not create cue in event because '%@' is not a valid cue trigger type. Valid types are 'timed', 'called', and 'timedWithCanon', and 'calledWithCanon'.", triggerTypeString];
        NSDictionary *tempDic = @{NSLocalizedDescriptionKey: errorDesc};
        *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Event.ErrorDomain" code:5 userInfo:tempDic];
        #ifdef DEBUG
        NSLog(@"%@", *error);
        #endif
    }
    
    if(!*error){
//        NSLog(@"mainValue: %@", mainValue);
        trigger = [[CHTrigger alloc] initWithValue:[mainValue doubleValue] ofType:triggerType forMediaType:mediaType error:&triggerError];
        
        if(!triggerError){
            if(trigger.type == CHTriggeredAtTimeWithCanon || trigger.type == CHTriggeredByServerSentEventWithCanon){
                trigger.canonDelay = [canonDelay doubleValue] * [_session.participantIndex doubleValue];
                
            }
        } else {
            *error = triggerError;
        }
    }
    
    return trigger;
}

@end
