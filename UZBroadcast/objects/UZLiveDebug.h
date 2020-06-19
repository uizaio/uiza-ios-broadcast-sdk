//
//  UZLiveDebug.h
//  UZLiveKit
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UZLiveDebug : NSObject

@property (nonatomic, copy) NSString *streamId;                     /// Stream Id
@property (nonatomic, copy) NSString *uploadUrl;                    /// Stream URL
@property (nonatomic, assign) CGSize videoSize;                     /// Video Resolution
@property (nonatomic, assign) BOOL isRtmp;                           /// Upload method（TCP or RTMP）

@property (nonatomic, assign) CGFloat elapsedMilli;                /// Time since last count in ms
@property (nonatomic, assign) CGFloat timeStamp;                   /// Current timestamp to calculate data within 1s
@property (nonatomic, assign) CGFloat dataFlow;                    /// Total flow
@property (nonatomic, assign) CGFloat bandwidth;                   /// Total bandwidth within 1s
@property (nonatomic, assign) CGFloat currentBandwidth;          /// Last bandwidth

@property (nonatomic, assign) NSInteger dropFrame;                ///< Frames dropped
@property (nonatomic, assign) NSInteger totalFrame;               /// Total frames

@property (nonatomic, assign) NSInteger capturedAudioCount;             /// Number of audio captures in 1s
@property (nonatomic, assign) NSInteger capturedVideoCount;             /// Number of video captures in 1s
@property (nonatomic, assign) NSInteger currentCapturedAudioCount;    /// Number of audio captures last time
@property (nonatomic, assign) NSInteger currentCapturedVideoCount;    /// Number of last video captures

@property (nonatomic, assign) NSInteger unSendCount;  /// Unsent number (representing the current buffer waiting to be sent)

@end
