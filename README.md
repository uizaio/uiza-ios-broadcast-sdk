<p align="center">
<img src="https://d3co7cvuqq9u2k.cloudfront.net/public/image/logo/uiza_logo_color.png" data-canonical-src="https://uiza.io" width="450" height="220" />
</p>


[![License BSD](https://img.shields.io/badge/license-BSD-success.svg?style=flat)](https://raw.githubusercontent.com/uizaio/uiza-ios-broadcast-sdk/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/UZBroadcast.svg?style=flat)](http://cocoapods.org/?q=UZBroadcast)&nbsp;
[![Build Status](https://travis-ci.org/uizaio/uiza-ios-broadcast-sdk.svg?branch=master)](https://travis-ci.org/uizaio/uiza-ios-broadcast-sdk)
![Platform](https://img.shields.io/badge/platform-ios-success.svg)&nbsp;
[![Support](https://img.shields.io/badge/ios-9-success.svg)](https://www.apple.com/nl/ios/)&nbsp;


**UZBroadcast is a opensource RTMP streaming SDK for iOS.**  

## Features

- [x] 	Background recording
- [x] 	Support horizontal vertical recording
- [x] 	Support Beauty Face With GPUImage
- [x] 	Support H264+AAC Hardware Encoding
- [x] 	Drop frames on bad network 
- [x] 	Dynamic switching rate
- [x] 	Audio configuration
- [x] 	Video configuration
- [x] 	RTMP and RTMPS Transport
- [x] 	Switch camera position
- [x] 	Audio Mute
- [x] 	Support Send Buffer
- [x] 	Support WaterMark
- [x] 	Swift Support
- [x] 	Support Single Video or Audio 
- [x] 	Support External input video or audio(Screen recording or Peripheral)
- [ ] 	~~FLV package and send~~

## Requirements
    - iOS 9.0+
    - Xcode 11
  
## Installation

#### CocoaPods
	# To integrate UZBroadcast into your Xcode project using CocoaPods, specify it in your Podfile:

	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '9.0'
	pod 'UZBroadcast'
	
	# Then, run the following command:
	$ pod install

#### Manually

    1. Download all the files in the `UZBroadcast` subdirectory.
    2. Add the source files to your Xcode project.
    3. Link with required frameworks:
        * UIKit
        * Foundation
        * AVFoundation
        * VideoToolbox
        * AudioToolbox
        * libz
        * libstdc++
        * [OpenSSL-Universal](https://github.com/krzyzanowskim/OpenSSL)
	
## Usage example 

#### Objective-C
```objc
- (UZBroadcastSession*)session {
	if (!_session) {
	    _session = [[UZBroadcastSession alloc] initWithAudioConfiguration:[UZAudioConfiguration defaultConfiguration] videoConfiguration:[UZVideoConfiguration defaultConfiguration]];
	    _session.preView = self;
	    _session.delegate = self;
	}
	return _session;
}

- (void)startBroadcast {	
	UZStreamInfo *streamInfo = [UZStreamInfo new];
	streamInfo.url = @"your server rtmp url";
	[self.session startBroadcast:streamInfo];
}

- (void)stopBroadcast {
	[self.session stopBroadcast];
}

//MARK: - CallBack:
- (void)broadcastSession:(nullable UZBroadcastSession *)session broadcastStateDidChange: (UZBroadcastState)state;
- (void)broadcastSession:(nullable UZBroadcastSession *)session debugInfo:(nullable UZBroadcastDebug*)debugInfo;
- (void)broadcastSession:(nullable UZBroadcastSession*)session errorCode:(UZSocketErrorCode)errorCode;
```

#### Swift

```swift
// import UZBroadcast in [ProjectName]-Bridging-Header.h
#import <UZBroadcast.h> 

//MARK: - Getters and Setters
lazy var session: UZBroadcastSession = {
	let audioConfiguration = UZAudioConfiguration.defaultConfiguration()
	let videoConfiguration = UZVideoConfiguration.defaultConfigurationForQuality(UZVideoQuality.SD_360, landscape: false)
	let session = UZBroadcastSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
	    
	session?.delegate = self
	session?.preView = self.view
	return session!
}()

//MARK: - Event
func startBroadcast() -> Void { 
	let stream = UZStreamInfo()
	stream.url = "your server rtmp url";
	session.startBroadcast(stream)
}

func stopBroadcast() -> Void {
	session.stopBroadcast()
}

//MARK: - Callback
func broadcastSession(session: UZBroadcastSession?, debugInfo: UZBroadcastDebug?) 
func broadcastSession(session: UZBroadcastSession?, errorCode: UZSocketErrorCode)
func broadcastSession(session: UZBroadcastSession?, broadcastStateDidChange state: UZBroadcastState)
```

Remember to add these usage description keys into `Info.plist` file:

```xml
<key>NSCameraUsageDescription</key>
<string>App needs access to camera for broadcasting</string>
<key>NSMicrophoneUsageDescription</key>
<string>App needs access to microphone for broadcasting</string>
```

## Reference
[API Reference](https://uizaio.github.io/uiza-ios-broadcast-sdk/)

## Support
developer@uiza.io

## License
UZBroadcast is released under the BSD license. See [LICENSE](https://github.com/uizaio/uiza-sdk-broadcast-ios/blob/master/LICENSE) for details.
