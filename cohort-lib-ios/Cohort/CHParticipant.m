//
//  CHParticipant.m
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-19.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import "CHParticipant.h"

@implementation CHParticipant

-(id)initWithTags:(NSSet *)tags error:(NSError **)error {
    if (self = [super init]) {
        // custom initialization
     
        if(!tags || tags.count == 0) {
            NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Warning: participant created without tags, adding 'all' tag"};
            if(error){
                *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Participant.ErrorDomain" code:1 userInfo:tempDic];
            }
            tags = [NSSet setWithObjects:@"all", nil];
        } else {
            if(![tags containsObject:@"all"]){
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for(NSString *tag in tags){
                    [tempArray addObject:tag];
                }
                [tempArray addObject:@"all"];
                tags = [NSSet setWithArray:tempArray];
                
                NSDictionary *tempDic = @{NSLocalizedDescriptionKey: @"Warning: participant created without 'all' tag, adding it"};
                *error = [[NSError alloc] initWithDomain:@"rocks.cohort.Participant.ErrorDomain" code:2 userInfo:tempDic];
            }
        }
        
        _tags = [NSSet setWithSet:tags];
    }
    return self;
}

@end
