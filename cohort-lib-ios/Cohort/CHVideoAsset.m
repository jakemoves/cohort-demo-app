//
//  CHVideoAsset.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-07-10.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "CHVideoAsset.h"

@implementation CHVideoAsset

@synthesize sourceFile = _sourceFile;
@synthesize mediaType = _mediaType;
@synthesize assetId = _assetId;

- (id)initWithAssetId:(NSString *)assetId inBundle:(NSBundle *)bundle andFilename:(NSString *)filename error:(NSError **)error {
    if (self = [super init]) {
        // custom initialization
        
        _mediaType = CHMediaTypeVideo;
        
        // not tested yet!
        if(assetId){
            if([assetId isEqualToString:@""]){
                NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create video asset because the assetId is an empty string"};
                *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Asset.ErrorDomain" code:2 userInfo:tempDic];
            } else {
                _assetId = assetId;
            }
        } else {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Could not create video asset because the assetId is nil"};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Episode.ErrorDomain" code:1 userInfo:tempDic];
        }
        
        NSString *assetPath = [bundle resourcePath];
        NSString *filepath = [assetPath stringByAppendingPathComponent:filename];
        if([[NSFileManager defaultManager] fileExistsAtPath: filepath] == NO)
        {
#ifdef DEBUG
            NSLog(@"Didn't find file");
#endif
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not create video asset because file '%@' does not exist at path ' %@", filename, filepath]};
            *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Asset.ErrorDomain" code:3 userInfo:tempDic];
        } else {
            _sourceFile = [[NSURL alloc] initWithString:filepath];
            
            // ~save basic info about asset? (i.e. duration?)
        }
        
        if(!_assetId || !_sourceFile){
            self = nil;
        }
    }
    
    return self;
}

@end
