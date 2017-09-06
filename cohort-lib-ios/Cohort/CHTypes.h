//
//  CHTypes.h
//  Cohort
//
//  Created by Jacob Niedzwiecki on 2015-06-27.
//  Copyright (c) 2015 Jacob Niedzwiecki. All rights reserved.
//

typedef NS_ENUM(NSInteger, CHMediaType) {
    CHMediaTypeUnknown,
    CHMediaTypeSound,
    CHMediaTypeEpisode,
    CHMediaTypeVideo
};

typedef NSString * CHMediaTypeString;
#define CHMediaTypeStringUnknown    @""
#define CHMediaTypeStringSound      @"sound"
#define CHMediaTypeStringEpisode    @"episode"
#define CHMediaTypeStringVideo      @"video"

typedef NS_ENUM(NSInteger, CHTriggerType) {
    CHTriggerTypeUnknown,
    CHTriggeredAtTime,
    CHTriggeredByServerSentEvent,
    CHTriggeredByUserInteraction,
    CHTriggeredByServerSentEventWithCanon,
    CHTriggeredAtTimeWithCanon
};

typedef NSString * CHTriggerActionType;
#define CHTriggerActionTypeUnknown  @""
#define CHTriggerActionTypeGo       @"go"

typedef void (^CHVoidBlock)();
