UZBroadcast
==============

[![License MIT](https://img.shields.io/badge/license-BSD-green.svg?style=flat)](https://raw.githubusercontent.com/uizaio/uiza-ios-broadcast-sdk/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/UZBroadcast.svg?style=flat)](http://cocoapods.org/?q=UZBroadcast)&nbsp;
[![Support](https://img.shields.io/badge/ios-9-orange.svg)](https://www.apple.com/nl/ios/)&nbsp;
![platform](https://img.shields.io/badge/platform-ios-ff69b4.svg)&nbsp;


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
	# To integrate UZLiveKit into your Xcode project using CocoaPods, specify it in your Podfile:

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
- (UZLiveSession*)session {
	if (!_session) {
	    _session = [[UZLiveSession alloc] initWithAudioConfiguration:[UZAudioConfiguration defaultConfiguration] videoConfiguration:[UZLiveVideoConfiguration defaultConfiguration]];
	    _session.preView = self;
	    _session.delegate = self;
	}
	return _session;
}

- (void)startLive {	
	UZStreamInfo *streamInfo = [UZStreamInfo new];
	streamInfo.url = @"your server rtmp url";
	[self.session startLive:streamInfo];
}

- (void)stopLive {
	[self.session stopLive];
}

//MARK: - CallBack:
- (void)liveSession:(nullable UZLiveSession *)session liveStateDidChange: (UZLiveState)state;
- (void)liveSession:(nullable UZLiveSession *)session debugInfo:(nullable UZLiveDebug*)debugInfo;
- (void)liveSession:(nullable UZLiveSession*)session errorCode:(UZSocketErrorCode)errorCode;
```

#### Swift

```swift
// import UZLiveKit in [ProjectName]-Bridging-Header.h
#import <UZLiveKit.h> 

//MARK: - Getters and Setters
lazy var session: UZLiveSession = {
	let audioConfiguration = UZAudioConfiguration.defaultConfiguration()
	let videoConfiguration = UZVideoConfiguration.defaultConfigurationForQuality(UZVideoQuality.SD_360, landscape: false)
	let session = UZLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
	    
	session?.delegate = self
	session?.preView = self.view
	return session!
}()

//MARK: - Event
func startLive() -> Void { 
	let stream = UZStreamInfo()
	stream.url = "your server rtmp url";
	session.startLive(stream)
}

func stopLive() -> Void {
	session.stopLive()
}

//MARK: - Callback
func liveSession(session: UZLiveSession?, debugInfo: UZLiveDebug?) 
func liveSession(session: UZLiveSession?, errorCode: UZSocketErrorCode)
func liveSession(session: UZLiveSession?, liveStateDidChange state: UZLiveState)
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
