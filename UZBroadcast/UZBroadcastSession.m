//
//  UZBroadcastSession.m
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "UZBroadcastSession.h"
#import "UZVideoCapture.h"
#import "UZAudioCapture.h"
#import "UZHardwareVideoEncoder.h"
#import "UZHardwareAudioEncoder.h"
#import "UZH264VideoEncoder.h"
#import "UZStreamRTMPSocket.h"
#import "UZStreamInfo.h"
#import "UZGPUImageBeautyFilter.h"
#import "UZH264VideoEncoder.h"


@interface UZBroadcastSession ()<UZAudioCaptureDelegate, UZVideoCaptureDelegate, UZAudioEncodingDelegate, UZVideoEncodingDelegate, UZStreamSocketDelegate>

/// Audio configuration
@property (nonatomic, strong) UZAudioConfiguration *audioConfiguration;
/// Video configuration
@property (nonatomic, strong) UZVideoConfiguration *videoConfiguration;
/// Audio Capture
@property (nonatomic, strong) UZAudioCapture *audioCaptureSource;
/// Video Capture
@property (nonatomic, strong) UZVideoCapture *videoCaptureSource;
/// Audio encoding
@property (nonatomic, strong) id<UZAudioEncoding> audioEncoder;
/// Video encoding
@property (nonatomic, strong) id<UZVideoEncoding> videoEncoder;
/// Stream socket
@property (nonatomic, strong) id<UZStreamSocket> socket;


#pragma mark -- Internal identification
/// Debug information
@property (nonatomic, strong) UZBroadcastDebug *debugInfo;
/// Stream info
@property (nonatomic, strong) UZStreamInfo *streamInfo;
/// Whether to start uploading
@property (nonatomic, assign) BOOL uploading;
/// Current state
@property (nonatomic, assign, readwrite) UZBroadcastState state;
/// Current live broadcast type
@property (nonatomic, assign, readwrite) UZCaptureTypeMask captureTypeMask;
/// Timestamp lock
@property (nonatomic, strong) dispatch_semaphore_t lock;


@end

/**  Timestamp */
#define NOW (CACurrentMediaTime()*1000)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface UZBroadcastSession ()

/// Upload relative timestamp
@property (nonatomic, assign) uint64_t relativeTimestamps;
/// Whether the audio and video are aligned
@property (nonatomic, assign) BOOL AVAlignment;
/// Whether audio is currently collected
@property (nonatomic, assign) BOOL hasCaptureAudio;
/// Whether the key frame is currently collected
@property (nonatomic, assign) BOOL hasKeyFrameVideo;

@end

@implementation UZBroadcastSession

#pragma mark -- LifeCycle
- (instancetype)initWithAudioConfiguration:(nullable UZAudioConfiguration *)audioConfiguration videoConfiguration:(nullable UZVideoConfiguration *)videoConfiguration {
    return [self initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration captureTypeMask:UZCaptureTypeMask_Default];
}

- (nullable instancetype)initWithAudioConfiguration:(nullable UZAudioConfiguration *)audioConfiguration videoConfiguration:(nullable UZVideoConfiguration *)videoConfiguration captureTypeMask:(UZCaptureTypeMask)captureTypeMask{
    if((captureTypeMask & UZCaptureTypeMask_Audio || captureTypeMask & UZCaptureTypeMask_InputAudio) && !audioConfiguration) @throw [NSException exceptionWithName:@"UZBroadcastSession init error" reason:@"audioConfiguration is nil " userInfo:nil];
    if((captureTypeMask & UZCaptureTypeMask_Video || captureTypeMask & UZCaptureTypeMask_InputVideo) && !videoConfiguration) @throw [NSException exceptionWithName:@"UZBroadcastSession init error" reason:@"videoConfiguration is nil " userInfo:nil];
    if (self = [super init]) {
        _audioConfiguration = audioConfiguration;
        _videoConfiguration = videoConfiguration;
        _adaptiveBitrate = NO;
        _captureTypeMask = captureTypeMask;
    }
    return self;
}

- (void)dealloc {
    _videoCaptureSource.running = NO;
    _audioCaptureSource.running = NO;
}

#pragma mark -- CustomMethod
- (void)startBroadcast:(UZStreamInfo *)streamInfo {
    if (!streamInfo) return;
    _streamInfo = streamInfo;
    _streamInfo.videoConfiguration = _videoConfiguration;
    _streamInfo.audioConfiguration = _audioConfiguration;
    [self.socket start];
}

- (void)stopBroadcast {
    self.uploading = NO;
    [self.socket stop];
    self.socket = nil;
}

- (void)pushAudioBuffer:(nullable CMSampleBufferRef)sampleBuffer {
	AudioBufferList audioBufferList;
	CMBlockBufferRef blockBuffer;
	
	CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
	
	for( int y=0; y<audioBufferList.mNumberBuffers; y++ ) {
		AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
		void* audio = audioBuffer.mData;
		NSData *data = [NSData dataWithBytes:audio length:audioBuffer.mDataByteSize];
		[self pushAudio:data];
	}
	CFRelease(blockBuffer);
}

- (void)pushVideoBuffer:(nullable CMSampleBufferRef)sampleBuffer {
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	[self pushVideo:pixelBuffer];
}

- (void)pushVideo:(nullable CVPixelBufferRef)pixelBuffer{
    if(self.captureTypeMask & UZCaptureTypeMask_InputVideo){
        if (self.uploading) [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:NOW];
    }
}

- (void)pushAudio:(nullable NSData*)audioData{
    if(self.captureTypeMask & UZCaptureTypeMask_InputAudio){
        if (self.uploading) [self.audioEncoder encodeAudioData:audioData timeStamp:NOW];
    }
}

#pragma mark -- PrivateMethod
- (void)pushSendBuffer:(UZFrame*)frame{
    if(self.relativeTimestamps == 0){
        self.relativeTimestamps = frame.timestamp;
    }
    frame.timestamp = [self uploadTimestamp:frame.timestamp];
    [self.socket sendFrame:frame];
}

#pragma mark -- CaptureDelegate
- (void)captureOutput:(nullable UZAudioCapture *)capture audioData:(nullable NSData*)audioData {
    if (self.uploading) [self.audioEncoder encodeAudioData:audioData timeStamp:NOW];
}

- (void)captureOutput:(nullable UZVideoCapture *)capture pixelBuffer:(nullable CVPixelBufferRef)pixelBuffer {
    if (self.uploading) [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:NOW];
}

#pragma mark -- EncoderDelegate
- (void)audioEncoder:(nullable id<UZAudioEncoding>)encoder audioFrame:(nullable UZAudioFrame *)frame {
    //Upload timestamp alignment
    if (self.uploading){
        self.hasCaptureAudio = YES;
        if(self.AVAlignment) [self pushSendBuffer:frame];
    }
}

- (void)videoEncoder:(nullable id<UZVideoEncoding>)encoder videoFrame:(nullable UZVideoFrame *)frame {
    //Upload timestamp alignment
    if (self.uploading){
        if(frame.isKeyFrame && self.hasCaptureAudio) self.hasKeyFrameVideo = YES;
        if(self.AVAlignment) [self pushSendBuffer:frame];
    }
}

#pragma mark -- UZStreamTcpSocketDelegate
- (void)socketStatus:(nullable id<UZStreamSocket>)socket status:(UZBroadcastState)status {
    if (status == UZBroadcastState_Start) {
        if (!self.uploading) {
            self.AVAlignment = NO;
            self.hasCaptureAudio = NO;
            self.hasKeyFrameVideo = NO;
            self.relativeTimestamps = 0;
            self.uploading = YES;
        }
    } else if(status == UZBroadcastState_Stop || status == UZBroadcastState_Error){
        self.uploading = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.state = status;
        if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastSession:broadcastStateDidChange:)]) {
            [self.delegate broadcastSession:self broadcastStateDidChange:status];
        }
    });
}

- (void)socketDidError:(nullable id<UZStreamSocket>)socket errorCode:(UZSocketErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastSession:errorCode:)]) {
            [self.delegate broadcastSession:self errorCode:errorCode];
        }
    });
}

- (void)socketDebug:(nullable id<UZStreamSocket>)socket debugInfo:(nullable UZBroadcastDebug *)debugInfo {
    self.debugInfo = debugInfo;
    if (self.showDebugInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastSession:debugInfo:)]) {
                [self.delegate broadcastSession:self debugInfo:debugInfo];
            }
        });
    }
}

- (void)socketBufferStatus:(nullable id<UZStreamSocket>)socket status:(UZBuffferState)status {
    if((self.captureTypeMask & UZCaptureTypeMask_Video || self.captureTypeMask & UZCaptureTypeMask_InputVideo) && self.adaptiveBitrate){
        NSUInteger videoBitRate = [self.videoEncoder videoBitRate];
        if (status == UZBuffferState_Decline) {
            if (videoBitRate < _videoConfiguration.videoMaxBitRate) {
                videoBitRate = videoBitRate + 50 * 1000;
                [self.videoEncoder setVideoBitRate:videoBitRate];
                NSLog(@"Increase bitrate %@", @(videoBitRate));
            }
        } else {
            if (videoBitRate > self.videoConfiguration.videoMinBitRate) {
                videoBitRate = videoBitRate - 100 * 1000;
                [self.videoEncoder setVideoBitRate:videoBitRate];
                NSLog(@"Decrease bitrate %@", @(videoBitRate));
            }
        }
    }
}

#pragma mark -- Getter Setter
- (void)setRunning:(BOOL)running {
    if (_running == running) return;
    [self willChangeValueForKey:@"running"];
    _running = running;
    [self didChangeValueForKey:@"running"];
    self.videoCaptureSource.running = _running;
    self.audioCaptureSource.running = _running;
}

- (void)setPreView:(UIView *)preView {
    [self willChangeValueForKey:@"preView"];
    [self.videoCaptureSource setPreView:preView];
    [self didChangeValueForKey:@"preView"];
}

- (UIView *)preView {
    return self.videoCaptureSource.preView;
}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition {
    [self willChangeValueForKey:@"captureDevicePosition"];
    [self.videoCaptureSource setCaptureDevicePosition:captureDevicePosition];
    [self didChangeValueForKey:@"captureDevicePosition"];
}

- (AVCaptureDevicePosition)captureDevicePosition {
    return self.videoCaptureSource.captureDevicePosition;
}

- (void)setBeautyFace:(BOOL)beautyFace {
    [self willChangeValueForKey:@"beautyFace"];
    [self.videoCaptureSource setBeautyFace:beautyFace];
    [self didChangeValueForKey:@"beautyFace"];
}

- (BOOL)saveLocalVideo{
    return self.videoCaptureSource.saveLocalVideo;
}

- (void)setSaveLocalVideo:(BOOL)saveLocalVideo{
    [self.videoCaptureSource setSaveLocalVideo:saveLocalVideo];
}


- (NSURL*)saveLocalVideoPath{
    return self.videoCaptureSource.saveLocalVideoPath;
}

- (void)setSaveLocalVideoPath:(NSURL*)saveLocalVideoPath{
    [self.videoCaptureSource setSaveLocalVideoPath:saveLocalVideoPath];
}

- (BOOL)beautyFace {
    return self.videoCaptureSource.beautyFace;
}

- (void)setBeautyLevel:(CGFloat)beautyLevel {
    [self willChangeValueForKey:@"beautyLevel"];
    [self.videoCaptureSource setBeautyLevel:beautyLevel];
    [self didChangeValueForKey:@"beautyLevel"];
}

- (CGFloat)beautyLevel {
    return self.videoCaptureSource.beautyLevel;
}

- (void)setBrightLevel:(CGFloat)brightLevel {
    [self willChangeValueForKey:@"brightLevel"];
    [self.videoCaptureSource setBrightLevel:brightLevel];
    [self didChangeValueForKey:@"brightLevel"];
}

- (CGFloat)brightLevel {
    return self.videoCaptureSource.brightLevel;
}

- (void)setZoomScale:(CGFloat)zoomScale {
    [self willChangeValueForKey:@"zoomScale"];
    [self.videoCaptureSource setZoomScale:zoomScale];
    [self didChangeValueForKey:@"zoomScale"];
}

- (CGFloat)zoomScale {
    return self.videoCaptureSource.zoomScale;
}

- (void)setContinuousAutoFocus:(BOOL)continuousAutoFocus {
	[self willChangeValueForKey:@"continuousAutoFocus"];
	[self.videoCaptureSource setContinuousAutoFocus:continuousAutoFocus];
	[self didChangeValueForKey:@"continuousAutoFocus"];
}

- (BOOL)continuousAutoFocus {
	return self.videoCaptureSource.continuousAutoFocus;
}

- (void)setContinuousAutoExposure:(BOOL)continuousAutoExposure {
	[self willChangeValueForKey:@"continuousAutoExposure"];
	[self.videoCaptureSource setContinuousAutoExposure:continuousAutoExposure];
	[self didChangeValueForKey:@"continuousAutoExposure"];
}

- (BOOL)continuousAutoExposure {
	return self.videoCaptureSource.continuousAutoExposure;
}

- (void)setTorch:(BOOL)torch {
    [self willChangeValueForKey:@"torch"];
    [self.videoCaptureSource setTorch:torch];
    [self didChangeValueForKey:@"torch"];
}

- (BOOL)torch {
    return self.videoCaptureSource.torch;
}

- (void)setMirror:(BOOL)mirror {
    [self willChangeValueForKey:@"mirror"];
    [self.videoCaptureSource setMirror:mirror];
    [self didChangeValueForKey:@"mirror"];
}

- (BOOL)mirror {
    return self.videoCaptureSource.mirror;
}

- (void)setMuted:(BOOL)muted {
    [self willChangeValueForKey:@"muted"];
    [self.audioCaptureSource setMuted:muted];
    [self didChangeValueForKey:@"muted"];
}

- (BOOL)muted {
    return self.audioCaptureSource.muted;
}

- (void)setWarterMarkView:(UIView *)warterMarkView{
    [self.videoCaptureSource setWarterMarkView:warterMarkView];
}

- (nullable UIView*)warterMarkView{
    return self.videoCaptureSource.warterMarkView;
}

- (nullable UIImage *)currentImage{
    return self.videoCaptureSource.currentImage;
}

- (UZAudioCapture *)audioCaptureSource {
    if (!_audioCaptureSource) {
        if(self.captureTypeMask & UZCaptureTypeMask_Audio){
            _audioCaptureSource = [[UZAudioCapture alloc] initWithAudioConfiguration:_audioConfiguration];
            _audioCaptureSource.delegate = self;
        }
    }
    return _audioCaptureSource;
}

- (UZVideoCapture *)videoCaptureSource {
    if (!_videoCaptureSource) {
        if(self.captureTypeMask & UZCaptureTypeMask_Video){
            _videoCaptureSource = [[UZVideoCapture alloc] initWithVideoConfiguration:_videoConfiguration];
            _videoCaptureSource.delegate = self;
        }
    }
    return _videoCaptureSource;
}

- (id<UZAudioEncoding>)audioEncoder {
    if (!_audioEncoder) {
        _audioEncoder = [[UZHardwareAudioEncoder alloc] initWithAudioStreamConfiguration:_audioConfiguration];
        [_audioEncoder setDelegate:self];
    }
    return _audioEncoder;
}

- (id<UZVideoEncoding>)videoEncoder {
    if (!_videoEncoder) {
        if([[UIDevice currentDevice].systemVersion floatValue] < 8.0){
            _videoEncoder = [[UZH264VideoEncoder alloc] initWithVideoStreamConfiguration:_videoConfiguration];
        }else{
            _videoEncoder = [[UZHardwareVideoEncoder alloc] initWithVideoStreamConfiguration:_videoConfiguration];
        }
        [_videoEncoder setDelegate:self];
    }
    return _videoEncoder;
}

- (id<UZStreamSocket>)socket {
    if (!_socket) {
        _socket = [[UZStreamRTMPSocket alloc] initWithStream:self.streamInfo reconnectInterval:self.reconnectInterval reconnectCount:self.reconnectCount];
        [_socket setDelegate:self];
    }
    return _socket;
}

- (UZStreamInfo *)streamInfo {
    if (!_streamInfo) {
        _streamInfo = [[UZStreamInfo alloc] init];
    }
    return _streamInfo;
}

- (dispatch_semaphore_t)lock{
    if(!_lock){
        _lock = dispatch_semaphore_create(1);
    }
    return _lock;
}

- (uint64_t)uploadTimestamp:(uint64_t)captureTimestamp{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    uint64_t currentts = 0;
    currentts = captureTimestamp - self.relativeTimestamps;
    dispatch_semaphore_signal(self.lock);
    return currentts;
}

- (BOOL)AVAlignment{
    if((self.captureTypeMask & UZCaptureTypeMask_Audio || self.captureTypeMask & UZCaptureTypeMask_InputAudio) &&
       (self.captureTypeMask & UZCaptureTypeMask_Video || self.captureTypeMask & UZCaptureTypeMask_InputVideo)
       ){
        if(self.hasCaptureAudio && self.hasKeyFrameVideo) return YES;
        else  return NO;
    }else{
        return YES;
    }
}

@end
