//
//  UZVideoConfiguration.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Video resolution (both 16:9 when the device does not support the current resolution, it will automatically decrease by one level)
typedef NS_ENUM (NSUInteger, UZVideoSessionPreset){
    /// Low resolution
    UZVideoSessionPreset360x640 = 0,
    /// Medium resolution
    UZVideoSessionPreset480x854 = 1,
	///
	UZVideoSessionPreset540x960 = 2,
    /// HD resolution
    UZVideoSessionPreset720x1280 = 3,
	/// FullHD resolution
	UZVideoSessionPreset1920x1080 = 4,
	/// 4K Resolution
	UZVideoSessionPreset3840x2160 = 5
};

/// Video quality
typedef NS_ENUM (NSUInteger, UZVideoQuality){
    /// 360
    UZVideoQuality_SD_360 = 0,
	/// 480
	UZVideoQuality_SD_480 = 1,
	/// 540
	UZVideoQuality_SD_540 = 2,
    /// 720
    UZVideoQuality_HD_720 = 3,
	/// 1080
	UZVideoQuality_FullHD_1080 = 4,
	/// 4K
	UZVideoQuality_UltraHD_4K = 5,
    ///default quality
    UZVideoQuality_Default = UZVideoQuality_HD_720
};

@interface UZVideoConfiguration : NSObject<NSCoding, NSCopying>

/// Default video configuration
+ (instancetype)defaultConfiguration;
/// Video configuration (quality)
+ (instancetype)defaultConfigurationForQuality:(UZVideoQuality)videoQuality;

/// Video configuration (quality & whether it is landscape)
+ (instancetype)defaultConfigurationForQuality:(UZVideoQuality)videoQuality outputImageOrientation:(UIInterfaceOrientation)outputImageOrientation;
+ (instancetype)defaultConfigurationForQuality:(UZVideoQuality)videoQuality outputImageOrientation:(UIInterfaceOrientation)outputImageOrientation encode:(BOOL)encode;

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/// Video resolution，The width and height must be set to a multiple of 2，Otherwise, green edges may appear during decoding and playback(this one videoSizeRespectingAspectRatio Set to YES may change)
@property (nonatomic, assign) CGSize videoSize;

/// Whether the output image is proportional, the default is NO
@property (nonatomic, assign) BOOL videoSizeRespectingAspectRatio;

/// Video output direction
@property (nonatomic, assign) UIInterfaceOrientation outputImageOrientation;

/// Automatic rotation (only left to right portrait to portraitUpsideDown is supported here)
@property (nonatomic, assign) BOOL autorotate;

/// The frame rate of the video, which is fps
@property (nonatomic, assign) NSUInteger videoFrameRate;

/// The maximum frame rate of the video，which is fps
@property (nonatomic, assign) NSUInteger videoMaxFrameRate;

///Video minimum frame rate，which is fps
@property (nonatomic, assign) NSUInteger videoMinFrameRate;

/// The maximum key frame interval can be set to twice the fps, affecting the gop size
@property (nonatomic, assign) NSUInteger videoMaxKeyframeInterval;

/// The bit rate of the video, the unit is bps
@property (nonatomic, assign) NSUInteger videoBitRate;

///The maximum bit rate of the video, the unit is bps
@property (nonatomic, assign) NSUInteger videoMaxBitRate;

/// The minimum bit rate of the video, the unit is bps
@property (nonatomic, assign) NSUInteger videoMinBitRate;

/// Resolution
@property (nonatomic, assign) UZVideoSessionPreset sessionPreset;

/// ≈sde3 resolution
@property (nonatomic, assign, readonly) NSString *avSessionPreset;

/// Is it horizontal
@property (nonatomic, assign, readonly) BOOL landscape;

@end
