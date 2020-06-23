//
//  UZBroadcastPreview.m
//  UZBroadcastDemo
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "UZBroadcastPreview.h"
#import "category/UIControl+YYAdd.h"
#import "category/UIView+YYAdd.h"
#import "UZBroadcast.h"

const CGFloat TOP_MARGIN = 44.0;

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }

    if (bytes <= 0) {
        return @"0 KB/s";
    }

    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}

@interface UZBroadcastPreview ()<UZBroadcastSessionDelegate>

@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *startBroadcastButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UZBroadcastDebug *debugInfo;
@property (nonatomic, strong) UZBroadcastSession *session;
@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation UZBroadcastPreview

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.stateLabel];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.beautyButton];
        [self.containerView addSubview:self.startBroadcastButton];
  
        
    }
    return self;
}
#pragma mark -- Public Method
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        // License dialogue does not appear, initiate license
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        // Authorization has been opened, you can continue
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.session setRunning:YES];
        });
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        // User explicitly denied authorization, or camera device is inaccessible

        break;
    default:
        break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        break;
    default:
        break;
    }
}

#pragma mark -- UZStreamingSessionDelegate
/** broadcast status changed will callback */
- (void)broadcastSession:(nullable UZBroadcastSession *)session broadcastStateDidChange:(UZBroadcastState)state {
    NSLog(@"broadcastStateDidChange: %ld", state);
    switch (state) {
    case UZBroadcastState_Ready:
        _stateLabel.text = @"No Connect";
        _stateLabel.textColor = UIColor.whiteColor;
        break;
    case UZBroadcastState_Pending:
        _stateLabel.text = @"Connecting";
        _stateLabel.textColor = UIColor.orangeColor;
        break;
    case UZBroadcastState_Start:
        _stateLabel.text = @"Connected";
        _stateLabel.textColor = UIColor.whiteColor;
        break;
    case UZBroadcastState_Error:
        _stateLabel.text = @"Connect Error";
        _stateLabel.textColor = UIColor.redColor;
        break;
    case UZBroadcastState_Stop:
        _stateLabel.text = @"No Connect";
        _stateLabel.textColor = UIColor.whiteColor;
        break;
    default:
        break;
    }
}

/** broadcast debug info callback */
- (void)broadcastSession:(nullable UZBroadcastSession *)session debugInfo:(nullable UZBroadcastDebug *)debugInfo {
    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

/** callback socket errorcode */
- (void)broadcastSession:(nullable UZBroadcastSession *)session errorCode:(UZSocketErrorCode)errorCode {
    NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter
- (UZBroadcastSession *)session {
    if (!_session) {
        UZVideoConfiguration *videoConfiguration = [UZVideoConfiguration new];
        videoConfiguration.videoSize = CGSizeMake(720, 1280);
        videoConfiguration.videoBitRate = 800*1024;
        videoConfiguration.videoMaxBitRate = 1000*1024;
        videoConfiguration.videoMinBitRate = 500*1024;
        videoConfiguration.videoFrameRate = 30;
        videoConfiguration.videoMaxKeyframeInterval = 48;
        videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;
        videoConfiguration.autorotate = NO;
        videoConfiguration.sessionPreset = UZVideoSessionPreset720x1280;
        _session = [[UZBroadcastSession alloc] initWithAudioConfiguration:[UZAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureTypeMask:UZCaptureTypeMask_Default];

        /**    Customize your own mono  */
        /*
           UZAudioConfiguration *audioConfiguration = [UZAudioConfiguration new];
           audioConfiguration.numberOfChannels = 1;
           audioConfiguration.audioBitrate = UZAudioBitRate_64Kbps;
           audioConfiguration.audioSampleRate = UZAudioSampleRate_44100Hz;
           _session = [[UZBroadcastSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[UZVideoConfiguration defaultConfiguration]];
         */

        /**    Customize high-quality audio 96K */
        /*
           UZAudioConfiguration *audioConfiguration = [UZAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = UZAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = UZAudioSampleRate_44100Hz;
           _session = [[UZBroadcastSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[UZVideoConfiguration defaultConfiguration]];
         */

        /**    Customize your own high-quality audio 96K resolution set to 540*960 vertical screen */

        /*
           UZAudioConfiguration *audioConfiguration = [UZAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = UZAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = UZAudioSampleRate_44100Hz;

           UZVideoConfiguration *videoConfiguration = [UZVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(540, 960);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 24;
           videoConfiguration.videoMaxKeyframeInterval = 48;
           videoConfiguration.orientation = UIInterfaceOrientationPortrait;
           videoConfiguration.sessionPreset = UZVideoSessionPreset540x960;

           _session = [[UZBroadcastSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    Customize high-quality audio with 128K resolution set to 720*1280 vertical screen */

        /*
           UZAudioConfiguration *audioConfiguration = [UZAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = UZAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = UZLiveAudioSampleRate_44100Hz;

           UZVideoConfiguration *videoConfiguration = [UZVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(720, 1280);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = NO;
           videoConfiguration.sessionPreset = UZVideoSessionPreset360x640;

           _session = [[UZBroadcastSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    Customize high-quality audio 128K resolution setting to 720*1280 horizontal landscape  */

        /*
           UZAudioConfiguration *audioConfiguration = [UZAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = UZAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = UZAudioSampleRate_44100Hz;

           UZVideoConfiguration *videoConfiguration = [UZVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(1280, 720);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = YES;
           videoConfiguration.sessionPreset = UZVideoSessionPreset720x1280;

           _session = [[UZBroadcastSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        */

        _session.delegate = self;
        _session.showDebugInfo = NO;
        _session.preView = self;
        
        /*Local storage*/
//        _session.saveLocalVideo = YES;
//        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
//        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//        _session.saveLocalVideoPath = movieURL;
        
        /*
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.alpha = 0.8;
        imageView.frame = CGRectMake(100, 100, 29, 29);
        imageView.image = [UIImage imageNamed:@"ios-29x29"];
        _session.warterMarkView = imageView;*/
        
    }
    return _session;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 40)];
        _stateLabel.text = @"No Connect";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:13.f];
        _stateLabel.top = TOP_MARGIN;
    }
    return _stateLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton new];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.left = self.width - 10 - _closeButton.width;
        _closeButton.top = TOP_MARGIN;
        [_closeButton setImage:[UIImage imageNamed:@"close_preview"] forState:UIControlStateNormal];
        _closeButton.exclusiveTouch = YES;
        [_closeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {

        }];
    }
    return _closeButton;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton new];
        _cameraButton.size = CGSizeMake(44, 44);
        _cameraButton.origin = CGPointMake(_closeButton.left - 10 - _cameraButton.width, 20);
        _cameraButton.top =TOP_MARGIN;
        [_cameraButton setImage:[UIImage imageNamed:@"camra_preview"] forState:UIControlStateNormal];
        _cameraButton.exclusiveTouch = YES;
        __weak typeof(self) _self = self;
        [_cameraButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            AVCaptureDevicePosition devicePositon = _self.session.captureDevicePosition;
            _self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        }];
    }
    return _cameraButton;
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        _beautyButton = [UIButton new];
        _beautyButton.size = CGSizeMake(44, 44);
        _beautyButton.origin = CGPointMake(_cameraButton.left - 10 - _beautyButton.width, 20);
        _beautyButton.top = TOP_MARGIN;
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateSelected];
        _beautyButton.exclusiveTouch = YES;
        __weak typeof(self) _self = self;
        [_beautyButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.session.beautyFace = !_self.session.beautyFace;
            _self.beautyButton.selected = !_self.session.beautyFace;
        }];
    }
    return _beautyButton;
}

- (UIButton *)startBroadcastButton {
    if (!_startBroadcastButton) {
        _startBroadcastButton = [UIButton new];
        _startBroadcastButton.size = CGSizeMake(self.width - 200, 46);
        _startBroadcastButton.left = 100;
        _startBroadcastButton.bottom = self.height - TOP_MARGIN;
        _startBroadcastButton.layer.cornerRadius = _startBroadcastButton.height/2;
        [_startBroadcastButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startBroadcastButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startBroadcastButton setTitle:@"Start Broadcast" forState:UIControlStateNormal];
        [_startBroadcastButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startBroadcastButton.exclusiveTouch = YES;
        __weak typeof(self) _self = self;
        [_startBroadcastButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.startBroadcastButton.selected = !_self.startBroadcastButton.selected;
            if (_self.startBroadcastButton.selected) {
                [_self.startBroadcastButton setTitle:@"Stop Broadcast" forState:UIControlStateNormal];
                UZStreamInfo *info = [UZStreamInfo new];
                info.url = @"rtmp://866a3630e8-in.streamwiz.dev/live/live_FBAO9ttz48";
                [_self.session startBroadcast:info];
            } else {
                [_self.startBroadcastButton setTitle:@"Start Broadcast" forState:UIControlStateNormal];
                [_self.session stopBroadcast];
            }
        }];
    }
    return _startBroadcastButton;
}

@end

