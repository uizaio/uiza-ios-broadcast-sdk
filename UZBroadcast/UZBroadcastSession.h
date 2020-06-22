//
//  UZBroadcastSession.h
//  UZBroadcast
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
#import "UZBroadcastDebug.h"



typedef NS_ENUM(NSInteger, UZCaptureType) {
    UZCaptureType_Audio,         /// capture only audio
    UZCaptureType_Video,         /// capture onlt video
    UZCaptureType_InputAudio,    /// only audio (External input audio)
    UZCaptureType_InputVideo,    /// only video (External input video)
};


///< Used to control the type of acquisition（Various combinations can be collected internally or externally，Support single audio and single video, External input is suitable for screen recording，Drones and other peripherals intervene）
typedef NS_ENUM(NSInteger,UZCaptureTypeMask) {
    UZCaptureTypeMask_Audio = (1 << UZCaptureType_Audio),     /// only inner capture audio (no video)
    UZCaptureTypeMask_Video = (1 << UZCaptureType_Video),     /// only inner capture video (no audio)
    UZCaptureTypeMask_InputAudio = (1 << UZCaptureType_InputAudio),    /// only outer input audio (no video)
    UZCaptureTypeMask_InputVideo = (1 << UZCaptureType_InputVideo),    /// only outer input video (no audio)
    UZCaptureTypeMask_All = (UZCaptureTypeMask_Audio | UZCaptureTypeMask_Video), /// inner capture audio and video
    UZCaptureTypeMask_InputAll = (UZCaptureTypeMask_InputAudio | UZCaptureTypeMask_InputVideo),    /// outer input audio and video(method see pushVideo and pushAudio)
    UZCaptureTypeMask_AudioInputVideo = (UZCaptureTypeMask_Audio | UZCaptureTypeMask_InputVideo), /// inner capture audio and outer input video(method pushVideo and setRunning)
    UZCaptureTypeMask_VideoInputAudio = (UZCaptureTypeMask_Video | UZCaptureTypeMask_InputAudio), /// inner capture video and outer input audio(method pushAudio and setRunning)
    UZCaptureTypeMask_Default = UZCaptureTypeMask_All   /// default is inner capture audio and video
};

@class UZBroadcastSession;
@protocol UZBroadcastSessionDelegate <NSObject>

@optional
/** broadcast status changed will callback */
- (void)broadcastSession:(nullable UZBroadcastSession *)session broadcastStateDidChange:(UZBroadcastState)state;
/** broadcast debug info callback */
- (void)broadcastSession:(nullable UZBroadcastSession *)session debugInfo:(nullable UZBroadcastDebug *)debugInfo;
/** callback socket errorcode */
- (void)broadcastSession:(nullable UZBroadcastSession *)session errorCode:(UZSocketErrorCode)errorCode;
@end

@class UZStreamInfo; 

@interface UZBroadcastSession : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/** The delegate of the capture. captureData callback */
@property (nullable, nonatomic, weak) id<UZBroadcastSessionDelegate> delegate;

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
@property (nonatomic, assign, readonly) UZBroadcastState state;

/** The captureType control inner or outer audio and video .*/
@property (nonatomic, assign, readonly) UZCaptureTypeMask captureTypeMask;

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
- (nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
   The designated initializer. Multiple instances with the same configuration will make the
   capture unstable.
 */
- (nullable instancetype)initWithAudioConfiguration:(nullable UZAudioConfiguration *)audioConfiguration videoConfiguration:(nullable UZVideoConfiguration *)videoConfiguration;

/**
 The designated initializer. Multiple instances with the same configuration will make the
 capture unstable.
 */
- (nullable instancetype)initWithAudioConfiguration:(nullable UZAudioConfiguration *)audioConfiguration videoConfiguration:(nullable UZVideoConfiguration *)videoConfiguration captureTypeMask:(UZCaptureTypeMask)captureTypeMask NS_DESIGNATED_INITIALIZER;

/** The start stream .*/
- (void)startBroadcast:(nonnull UZStreamInfo *)streamInfo;

/** The stop stream .*/
- (void)stopBroadcast;

/** support outer input yuv or rgb video(set UZCaptureTypeMask) .*/
- (void)pushVideo:(nullable CVPixelBufferRef)pixelBuffer;

/** support outer input pcm audio(set UZCaptureTypeMask) .*/
- (void)pushAudio:(nullable NSData*)audioData;

- (void)pushAudioBuffer:(nullable CMSampleBufferRef)sampleBuffer;
- (void)pushVideoBuffer:(nullable CMSampleBufferRef)sampleBuffer;

@end

