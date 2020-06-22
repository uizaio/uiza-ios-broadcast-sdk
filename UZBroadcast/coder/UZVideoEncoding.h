//
//  UZVideoEncoding.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UZVideoFrame.h"
#import "UZVideoConfiguration.h"

@protocol UZVideoEncoding;
/// Encoder delegate
@protocol UZVideoEncodingDelegate <NSObject>
@required
- (void)videoEncoder:(nullable id<UZVideoEncoding>)encoder videoFrame:(nullable UZVideoFrame *)frame;
@end

/// Encoder abstract interface
@protocol UZVideoEncoding <NSObject>
@required
- (void)encodeVideoData:(nullable CVPixelBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;
@optional
@property (nonatomic, assign) NSInteger videoBitRate;
- (nullable instancetype)initWithVideoStreamConfiguration:(nullable UZVideoConfiguration *)configuration;
- (void)setDelegate:(nullable id<UZVideoEncodingDelegate>)delegate;
- (void)stopEncoder;
@end

