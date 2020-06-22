//
//  UZAudioEncoding.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UZAudioFrame.h"
#import "UZAudioConfiguration.h"



@protocol UZAudioEncoding;
/// Audio delegate
@protocol UZAudioEncodingDelegate <NSObject>
@required
- (void)audioEncoder:(nullable id<UZAudioEncoding>)encoder audioFrame:(nullable UZAudioFrame *)frame;
@end

/// Encoder abstract interface
@protocol UZAudioEncoding <NSObject>
@required
- (void)encodeAudioData:(nullable NSData*)audioData timeStamp:(uint64_t)timeStamp;
- (void)stopEncoder;
@optional
- (nullable instancetype)initWithAudioStreamConfiguration:(nullable UZAudioConfiguration *)configuration;
- (void)setDelegate:(nullable id<UZAudioEncodingDelegate>)delegate;
- (nullable NSData *)adtsData:(NSInteger)channel rawDataLength:(NSInteger)rawDataLength;
@end

