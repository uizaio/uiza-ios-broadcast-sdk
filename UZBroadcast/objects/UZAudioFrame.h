//
//  UZAudioFrame.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "UZFrame.h"

@interface UZAudioFrame : UZFrame

/// flv打包中aac的header
@property (nonatomic, strong) NSData *audioInfo;

@end
