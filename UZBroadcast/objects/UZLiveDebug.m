//
//  LFLiveDebug.m
//  LaiFeng
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "UZLiveDebug.h"

@implementation UZLiveDebug

- (NSString *)description {
	return [NSString stringWithFormat:@"DropFrame:%ld TotalFrames:%ld AudioCount:%d VideoCount:%d UnsendCount:%ld TotalFlow:%0.f",(long)_dropFrame,(long)_totalFrame,_currentCapturedAudioCount,_currentCapturedVideoCount,(long)_unSendCount,_dataFlow];
}


@end
