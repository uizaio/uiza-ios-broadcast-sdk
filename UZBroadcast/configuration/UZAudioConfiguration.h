//
//  UZAudioConfiguration.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Audio bit rate (default 96Kbps)
typedef NS_ENUM (NSUInteger, UZAudioBitRate) {
    /// 32Kbps Audio bitrate
    UZAudioBitRate_32Kbps = 32000,
    /// 64Kbps Audio bitrate
    UZAudioBitRate_64Kbps = 64000,
    /// 96Kbps Audio bitrate
    UZAudioBitRate_96Kbps = 96000,
    /// 128Kbps Audio bitrate
    UZAudioBitRate_128Kbps = 128000,
    /// The default audio bitrate, the default is 96Kbps
    UZAudioBitRate_Default = UZAudioBitRate_96Kbps
};

/// Audio sampling rate (default 44.1KHz)
typedef NS_ENUM (NSUInteger, UZAudioSampleRate){
    /// 16KHz Audio SampleRate
    UZAudioSampleRate_16000Hz = 16000,
    /// 44.1KHz Audio SampleRate
    UZAudioSampleRate_44100Hz = 44100,
    /// 48KHz Audio SampleRate
    UZAudioSampleRate_48000Hz = 48000,
    /// The default audio samplerate，the default is 44.1KHz
    UZAudioSampleRate_Default = UZAudioSampleRate_44100Hz
};

///  Audio Broadcast quality
typedef NS_ENUM (NSUInteger, UZAudioQuality){
    /// Low: audio sample rate: 16KHz audio bitrate: numberOfChannels 1 : 32Kbps  2 : 64Kbps
    UZAudioQuality_Low = 0,
    /// Medium: audio sample rate: 44.1KHz audio bitrate: 96Kbps
    UZAudioQuality_Medium = 1,
    /// High: audio sample rate: 44.1MHz audio bitrate: 128Kbps
    UZAudioQuality_High = 2,
    /// Very High: audio sample rate: 48KHz, audio bitrate: 128Kbps
    UZAudioQuality_VeryHigh = 3,
    /// Default: audio sample rate: 44.1KHz, audio bitrate: 96Kbps
    UZAudioQuality_Default = UZAudioQuality_High
};

@interface UZAudioConfiguration : NSObject<NSCoding, NSCopying>

/// Default audio configuration
+ (instancetype)defaultConfiguration;
/// Audio configuration
+ (instancetype)defaultConfigurationForQuality:(UZAudioQuality)audioQuality;

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/// Number of channels (default 2)
@property (nonatomic, assign) NSUInteger numberOfChannels;
/// SampleRate
@property (nonatomic, assign) UZAudioSampleRate audioSampleRate;
/// BitRate
@property (nonatomic, assign) UZAudioBitRate audioBitrate;
/// flv encoded audio header 44100 is 0x12 0x10
@property (nonatomic, assign, readonly) char *asc;
/// Buffer length
@property (nonatomic, assign,readonly) NSUInteger bufferLength;

@end
