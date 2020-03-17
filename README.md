# UZBroadcast

<!-- [![CI Status](http://img.shields.io/travis/uizaio/UZBroadcast.svg?style=flat)](https://travis-ci.org/uizaio/UZBroadcast) -->
[![Version](https://img.shields.io/cocoapods/v/UZBroadcast.svg?style=flat)](http://cocoapods.org/pods/UZBroadcast)
[![License](https://img.shields.io/cocoapods/l/UZBroadcast.svg?style=flat)](http://cocoapods.org/pods/UZBroadcast)
[![Platform](https://img.shields.io/cocoapods/p/UZBroadcast.svg?style=flat)](http://cocoapods.org/pods/UZBroadcast)
![Swift](https://img.shields.io/badge/%20in-swift%205.0-orange.svg)

UZBroadcast is a framework helps you to broadcast livestream

## Compatibility
UZBroadcast requires Swift 4.2+ and iOS 9+

## Installation

### CocoaPods
To integrate UZBroadcast into your Xcode project using [CocoaPods](http://cocoapods.org), specify it in your `Podfile`:

```ruby
pod 'UZBroadcast'
```

Then run the following command:

```bash
$ pod install
```

## Usage

```swift
let viewController = UZLiveStreamViewController()
viewController.liveEventId = ENTITY_ID
self.present(viewController, animated: true, completion: nil)
```

Remember to add these usage description keys into `Info.plist` file:
```xml
<key>NSCameraUsageDescription</key>
<string>App needs access to camera for livestream</string>
<key>NSMicrophoneUsageDescription</key>
<string>App needs access to microphone for livestream</string>
```

## Support
namnh@uiza.io

## License
UZBroadcast is released under the BSD license. See [LICENSE](https://github.com/uizaio/uiza-sdk-broadcast-ios/blob/master/LICENSE) for details.