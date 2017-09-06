//
//  CHParticipant.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-19.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTypes.h"

@interface CHParticipant : NSObject

@property (strong) NSSet *tags;

-(id)initWithTags:(NSSet *)tags error:(NSError **)error;

@end
