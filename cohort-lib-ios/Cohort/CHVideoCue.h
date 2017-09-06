//
//  CHVideoCue.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-07-10.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CHCueable.h"
#import "CHSession.h"
#import "CHVideoAsset.h"
#import "CHTrigger.h"

@interface CHVideoCue : NSObject <CHCueable>

@property (strong, nonatomic) CHSession *session;
@property (strong, nonatomic) CHVideoAsset *asset;
@property (strong, nonatomic) MPMoviePlayerController *video;

- (id)initWithSession: (CHSession *)session andAsset:(CHVideoAsset *)asset withTriggers:(NSArray *)triggers withTags:(NSSet *)tags error:(NSError **)error withCompletionBlock:(CHVoidBlock)completionBlock;

@end
