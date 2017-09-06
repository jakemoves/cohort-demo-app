//
//  CHEvent.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-19.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTypes.h"
#import "CHParticipant.h"
#import "CHEpisode.h"
#import "CHSoundCue.h"
#import "CHSoundAsset.h"

@interface CHEvent : NSObject

@property (strong, nonatomic) NSDictionary *showbook;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *episodes;

@property (strong, nonatomic) CHSession *session;

//@property (strong, nonatomic) NSMutableDictionary *assets;
//@property (strong, nonatomic) CHParticipant *participant;

-(id)initWithJSONShowbook:(NSString *)showbookFilename andSession:(CHSession *) session inBundle:(NSBundle *)bundle error:(NSError **)error;
-(NSError *)loadEpisodes;

@end
