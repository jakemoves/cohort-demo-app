//
//  CHMediaAsset.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-09.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTypes.h"

@protocol CHMediaAsset <NSObject>

@property (strong, nonatomic) NSURL *sourceFile;
@property (readonly, nonatomic) CHMediaType mediaType;
@property (readonly, nonatomic) NSString *assetId;

- (id)initWithAssetId:(NSString *)assetId inBundle:(NSBundle *)bundle andFilename:(NSString *)filename error:(NSError **)error;

@end
