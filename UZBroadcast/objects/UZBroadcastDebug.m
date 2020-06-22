//
//  UZBroadcastDebug.m
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "UZBroadcastDebug.h"

@implementation UZBroadcastDebug

- (NSString *)description {
    return [NSString stringWithFormat:@"DropFrame:%ld TotalFrames:%ld AudioCount:%ld VideoCount:%ld UnsendCount:%ld TotalFlow:%0.f",(long)_dropFrame,(long)_totalFrame,(long)_currentCapturedAudioCount,(long)_currentCapturedVideoCount,(long)_unSendCount,_dataFlow];
}


@end
