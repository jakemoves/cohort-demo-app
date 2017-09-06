//
//  CHSoundAsset.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-09.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHMediaAsset.h"

@interface CHSoundAsset : NSObject <CHMediaAsset>

- (id)initWithAssetId:(NSString *)assetId atPath:(NSString *)filePath andFilename:(NSString *)filename error:(NSError **)error;

@end
