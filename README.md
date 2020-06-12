# UZBroadcast
![Swift](https://img.shields.io/badge/%20in-swift%205.0-orange.svg)

UZBroadcast is a framework helps you to broadcast livestream

## Compatibility
UZBroadcast requires Swift 4.2+ and iOS 9+

## Installation

### CocoaPods
To integrate UZBroadcast into your Xcode project using [CocoaPods](http://cocoapods.org), specify it in your `Podfile`:

```ruby
use_modular_headers!
pod 'UZBroadcast'
```

Since this framework includes static libraries then you may have to set `use_modular_headers!` globally in your Podfile, or specify `:modular_headers => true` for particular dependencies.

Then run the following command:

```bash
$ pod install
```

## Livestream

```swift
let broadcaster = UZBroadcastViewController()
let config = UZBroadcastConfig(cameraPosition: .front, videoResolution: ._720, videoBitrate: ._3000, videoFPS: ._30, audioBitrate: ._128Kbps, audioSampleRate: ._44_1khz, adaptiveBitrate: true)
broadcaster.prepareForBroadcast(config: config)
//...
broadcaster.startBroadcast(broadcastURL: BROADCAST_URL, streamKey: STREAM_KEY)
present(broadcaster, animated: true, completion: nil)
```

## Screen broadcast

```swift
let broadcaster = UZScreenBroadcast()
let config = UZBroadcastConfig(cameraPosition: .front, videoResolution: ._720, videoBitrate: ._3000, videoFPS: ._30, audioBitrate: ._128Kbps, audioSampleRate: ._44_1khz, adaptiveBitrate: true)
broadcaster.prepareForBroadcast(config: config)
//broadcaster.isMicrophoneEnabled = true
//broadcaster.isCameraEnabled = true
broadcaster.startBroadcast(broadcastURL: BROADCAST_URL, streamKey: STREAM_KEY)
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
namnh@uiza.io

## License
UZBroadcast is released under the BSD license. See [LICENSE](https://github.com/uizaio/uiza-sdk-broadcast-ios/blob/master/LICENSE) for details.
