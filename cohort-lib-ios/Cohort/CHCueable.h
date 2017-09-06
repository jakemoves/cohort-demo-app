//
//  CHCueing.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-08.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTypes.h"

@protocol CHCueable <NSObject>
@property (strong, nonatomic) NSSet *targetTags;
@property (readonly, nonatomic) CHMediaType mediaType;
@property (readonly, nonatomic) CHMediaTypeString mediaTypeAsString;
@property (readonly, nonatomic) NSArray *triggers;
@property (nonatomic) double duration;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, copy) CHVoidBlock completionBlock;
// usually an implementation of CHCueable will include a CHMediaAsset, but not always (i.e. an episode has only cues, no assets)
// implementations of CHCueable should include an accessible alternative (i.e. alt text for a CHSoundCue) for users with disabilities


-(void) load:(NSError **)error;
-(void) loadWithAccessibleAlternative:(NSError **)error;
-(void) fire;
-(void) play;
-(void) pause;
// add unload/stop?

@end