//
//  UZLiveSession.h
//  UZLiveKit
//
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UZStreamInfo.h"
#import "UZAudioFrame.h"
#import "UZVideoFrame.h"
#import "UZAudioConfiguration.h"
#import "UZVideoConfiguration.h"
#import "UZLiveDebug.h"



typedef NS_ENUM(NSInteger,UZLiveCaptureType) {
    UZLiveCaptureAudio,         ///< capture only audio
    UZLiveCaptureVideo,         ///< capture onlt video
    UZLiveInputAudio,           ///< only audio (External input audio)
    UZLiveInputVideo,           ///< only video (External input video)
};


///< Used to control the type of acquisition（Various combinations can be collected internally or externally，Support single audio and single video, External input is suitable for screen recording，Drones and other peripherals intervene）
typedef NS_ENUM(NSInteger,UZLiveCaptureTypeMask) {
    UZLiveCaptureMaskAudio = (1 << UZLiveCaptureAudio),                                 ///< only inner capture audio (no video)
    UZLiveCaptureMaskVideo = (1 << UZLiveCaptureVideo),                                 ///< only inner capture video (no audio)
    UZLiveInputMaskAudio = (1 << UZLiveInputAudio),                                     ///< only outer input audio (no video)
    UZLiveInputMaskVideo = (1 << UZLiveInputVideo),                                     ///< only outer input video (no audio)
    UZLiveCaptureMaskAll = (UZLiveCaptureMaskAudio | UZLiveCaptureMaskVideo),           ///< inner capture audio and video
    UZLiveInputMaskAll = (UZLiveInputMaskAudio | UZLiveInputMaskVideo),                 ///< outer input audio and video(method see pushVideo and pushAudio)
    UZLiveCaptureMaskAudioInputVideo = (UZLiveCaptureMaskAudio | UZLiveInputMaskVideo), ///< inner capture audio and outer input video(method pushVideo and setRunning)
    UZLiveCaptureMaskVideoInputAudio = (UZLiveCaptureMaskVideo | UZLiveInputMaskAudio), ///< inner capture video and outer input audio(method pushAudio and setRunning)
    UZLiveCaptureDefaultMask = UZLiveCaptureMaskAll                                     ///< default is inner capture audio and video
};

@class UZLiveSession;
@protocol UZLiveSessionDelegate <NSObject>

@optional
/** live status changed will callback */
- (void)liveSession:(nullable UZLiveSession *)session liveStateDidChange:(UZLiveState)state;
/** live debug info callback */
- (void)liveSession:(nullable UZLiveSession *)session debugInfo:(nullable UZLiveDebug *)debugInfo;
/** callback socket errorcode */
- (void)liveSession:(nullable UZLiveSession *)session errorCode:(UZSocketErrorCode)errorCode;
@end

@class UZStreamInfo; 

@interface UZLiveSession : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/** The delegate of the capture. captureData callback */
@property (nullable, nonatomic, weak) id<UZLiveSessionDelegate> delegate;

/** The running control start capture or stop capture*/
@property (nonatomic, assign) BOOL running;

/** The preView will show OpenGL ES view*/
@property (nonatomic, strong, null_resettable) UIView *preView;

/** The captureDevicePosition control camraPosition ,default front*/
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

/** The beautyFace control capture shader filter empty or beautiy */
@property (nonatomic, assign) BOOL beautyFace;

/** The beautyLevel control beautyFace Level. Default is 0.5, between 0.0 ~ 1.0 */
@property (nonatomic, assign) CGFloat beautyLevel;

/** The brightLevel control brightness Level, Default is 0.5, between 0.0 ~ 1.0 */
@property (nonatomic, assign) CGFloat brightLevel;

/** The torch control camera zoom scale default 1.0, between 1.0 ~ 3.0 */
@property (nonatomic, assign) CGFloat zoomScale;

/** The continuousAutoFocus control continuousAutoFocus is on or off */
@property (nonatomic, assign) BOOL continuousAutoFocus;

/** The continuousAutoExposure control continuousAutoExposure is on or off */
@property (nonatomic, assign) BOOL continuousAutoExposure;

/** The torch control capture flash is on or off */
@property (nonatomic, assign) BOOL torch;

/** The mirror control mirror of front camera is on or off */
@property (nonatomic, assign) BOOL mirror;

/** The muted control callbackAudioData,muted will memset 0.*/
@property (nonatomic, assign) BOOL muted;

/*  The adaptiveBitrate control auto adjust bitrate. Default is NO */
@property (nonatomic, assign) BOOL adaptiveBitrate;

/** The stream control upload and package*/
@property (nullable, nonatomic, strong, readonly) UZStreamInfo *streamInfo;

/** The status of the stream .*/
@property (nonatomic, assign, readonly) UZLiveState state;

/** The captureType control inner or outer audio and video .*/
@property (nonatomic, assign, readonly) UZLiveCaptureTypeMask captureType;

/** The showDebugInfo control streamInfo and uploadInfo(1s) *.*/
@property (nonatomic, assign) BOOL showDebugInfo;

/** The reconnectInterval control reconnect timeInterval(Reconnect interval) *.*/
@property (nonatomic, assign) NSUInteger reconnectInterval;

/** The reconnectCount control reconnect count (Reconnect times) *.*/
@property (nonatomic, assign) NSUInteger reconnectCount;

/*** The warterMarkView control whether the watermark is displayed or not ,if set ni,will remove watermark,otherwise add. 
 set alpha represent mix.Position relative to outVideoSize.
 *.*/
@property (nonatomic, strong, nullable) UIView *warterMarkView;

/* The currentImage is videoCapture shot */
@property (nonatomic, strong,readonly ,nullable) UIImage *currentImage;

/* The saveLocalVideo is save the local video */
@property (nonatomic, assign) BOOL saveLocalVideo;

/* The saveLocalVideoPath is save the local video  path */
@property (nonatomic, strong, nullable) NSURL *saveLocalVideoPath;

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
   The designated initializer. Multiple instances with the same configuration will make the
   capture unstable.
 */
- (nullable instancetype)initWithAudioConfiguration:(nullable UZAudioConfiguration *)audioConfiguration videoConfiguration:(nullable UZVideoConfiguration *)videoConfiguration;

/**
 The designated initializer. Multiple instances with the same configuration will make the
 capture unstable.
 */
- (nullable instancetype)initWithAudioConfiguration:(nullable UZAudioConfiguration *)audioConfiguration videoConfiguration:(nullable UZVideoConfiguration *)videoConfiguration captureType:(UZLiveCaptureTypeMask)captureType NS_DESIGNATED_INITIALIZER;

/** The start stream .*/
- (void)startLive:(nonnull UZStreamInfo *)streamInfo;

/** The stop stream .*/
- (void)stopLive;

/** support outer input yuv or rgb video(set UZLiveCaptureTypeMask) .*/
- (void)pushVideo:(nullable CVPixelBufferRef)pixelBuffer;

/** support outer input pcm audio(set UZLiveCaptureTypeMask) .*/
- (void)pushAudio:(nullable NSData*)audioData;

- (void)pushAudioBuffer:(nullable CMSampleBufferRef)sampleBuffer;
- (void)pushVideoBuffer:(nullable CMSampleBufferRef)sampleBuffer;

@end

