//
//  UZLiveView.swift
//  UizaSDK
//
//  Created by Nam Kennic on 8/28/18.
//  Copyright © 2018 Nam Kennic. All rights reserved.
//

import UIKit
import LFLiveKit_

public enum UZVideoResolution: CaseIterable {
	case _360
	case _480
	case _720
	case _1080
	
	var videoSize: CGSize {
		switch self {
		case ._360:
			return CGSize(width: 360, height: 640)
		case ._480:
			return CGSize(width: 480, height: 854)
		case ._720:
			return CGSize(width: 720, height: 1280)
		case ._1080:
			return CGSize(width: 1080, height: 1920)
		}
	}
	
	var sessionPreset: LFLiveVideoSessionPreset {
		switch self {
		case ._360:
			return .captureSessionPreset360x640
		case ._480:
			return .captureSessionPreset480x854
		case ._720:
			return .captureSessionPreset720x1280
		case ._1080:
			return .captureSessionPreset1920x1080
		}
	}
	
	func toString() -> String {
		var result = ""
		switch self {
		case ._360:
			result = "SD 360p"
		case ._480:
			result = "SD 480p"
		case ._720:
			result = "HD 720"
		case ._1080:
			result = "FullHD 1080"
		}
		
		return result + " (\(Int(videoSize.width))x\(Int(videoSize.height)))"
	}
	
}

public enum UZVideoBitrate: UInt, CaseIterable {
	case _500 = 500
	case _1000 = 1000
	case _1500 = 1500
	case _2000 = 2000
	case _3000 = 3000
	case _4000 = 4000
	case _5000 = 5000
	case _6000 = 6000
	
	func toString() -> String {
		return "\(self.rawValue) Kbps"
	}
}

public enum UZVideoFPS: UInt, CaseIterable {
	case _30 = 30
	case _60 = 60
	
	func toString() -> String {
		return "\(self.rawValue) fps"
	}
}

public enum UZAudioBitrate: UInt, CaseIterable {
	case _64Kbps = 64000
	case _96Kbps = 96000
	case _128Kbps = 128000
	
	func toLFLiveAudioBitRate() -> LFLiveAudioBitRate {
		switch self {
		case ._64Kbps:
			return ._64Kbps
		case ._96Kbps:
			return ._96Kbps
		case ._128Kbps:
			return ._128Kbps
		}
	}
	
	func toString() -> String {
		return "\(self.rawValue/1000) Kbps"
	}
}

public enum UZAudioSampleRate: UInt, CaseIterable {
	case _44_1khz = 44100
	case _48_0khz = 48000
	
	func toLFLiveAudioSampleRate() -> LFLiveAudioSampleRate {
		switch self {
		case ._44_1khz:
			return ._44100Hz
		case ._48_0khz:
			return ._48000Hz
		}
	}
	
	func toString() -> String {
		return "\(Double(self.rawValue)/1000) KHz"
	}
}

public struct UZBroadcastConfig {
	public var cameraPosition: AVCaptureDevice.Position
	public var videoResolution: UZVideoResolution
	public var videoBitrate: UZVideoBitrate
	public var videoFPS: UZVideoFPS
	public var audioBitrate: UZAudioBitrate
	public var audioSampleRate: UZAudioSampleRate
	public var adaptiveBitrate: Bool
	public var orientation: UIInterfaceOrientation?
	public var autoRotate: Bool?
}

extension UIApplication {
	
	var interfaceOrientation: UIInterfaceOrientation? {
		if #available(iOS 13, *) {
			return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation
		}
		else {
			return UIApplication.shared.statusBarOrientation
		}
	}
	
}

open class UZBroadcastViewController: UIViewController {
	public fileprivate(set)var isBroadcasting = false
	public fileprivate(set) var config: UZBroadcastConfig!
	
	lazy open var session: LFLiveSession = {
		let audioConfiguration = LFLiveAudioConfiguration()
		audioConfiguration.audioBitrate = config.audioBitrate.toLFLiveAudioBitRate()
		audioConfiguration.audioSampleRate = config.audioSampleRate.toLFLiveAudioSampleRate()
		
		let videoConfiguration = LFLiveVideoConfiguration()
		videoConfiguration.videoBitRate = config.videoBitrate.rawValue
		videoConfiguration.videoMaxBitRate = config.videoBitrate.rawValue
		videoConfiguration.videoMinBitRate = config.videoBitrate.rawValue/2
		videoConfiguration.videoFrameRate = config.videoFPS.rawValue
		videoConfiguration.videoMaxFrameRate = config.videoFPS.rawValue
		videoConfiguration.videoMinFrameRate = config.videoFPS.rawValue
		videoConfiguration.videoMaxKeyframeInterval = config.videoFPS.rawValue * 2
		videoConfiguration.videoSize = config.videoResolution.videoSize
		videoConfiguration.sessionPreset = config.videoResolution.sessionPreset
		videoConfiguration.outputImageOrientation = config.orientation ?? UIApplication.shared.interfaceOrientation ?? .portrait
		videoConfiguration.autorotate = false
		
		let result = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)!
		result.adaptiveBitrate = config.adaptiveBitrate
		result.beautyFace = false
		result.preView = self.view
		
		return result
	}()
	
	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	open override var shouldAutorotate: Bool {
		return config.autoRotate ?? (UIDevice.current.userInterfaceIdiom == .pad)
	}
	
	open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return config.autoRotate == true ? .all : (UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all)
	}
	
	open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return UIDevice.current.userInterfaceIdiom == .pad ? UIApplication.shared.interfaceOrientation ?? .portrait : .portrait
	}
	
	// MARK: -
	
	open func requestAccessForVideo() {
		let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
		switch status {
		case AVAuthorizationStatus.notDetermined:
			AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
				if granted {
					DispatchQueue.main.async {
						self.session.running = true
					}
				}
			})
		case AVAuthorizationStatus.authorized:
			session.running = true
		case AVAuthorizationStatus.denied: break
		case AVAuthorizationStatus.restricted:break
		@unknown default:break
		}
	}
	
	open func requestAccessForAudio() {
		let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
		switch status {
		case AVAuthorizationStatus.notDetermined:
			AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (_) in })
			
		case AVAuthorizationStatus.authorized: break
		case AVAuthorizationStatus.denied: break
		case AVAuthorizationStatus.restricted:break
		@unknown default:break
		}
	}
	
	public func prepareForBroadcast(withConfig config: UZBroadcastConfig) {
		self.config = config
		requestAccessForVideo()
		requestAccessForAudio()
	}
	
	public func startBroadcast(broadcastURL: URL) {
		isBroadcasting = true
		
		let stream = LFLiveStreamInfo()
		stream.url = broadcastURL.absoluteString
		session.startLive(stream)
		
		UIApplication.shared.isIdleTimerDisabled = true
	}
	
	public func stopBroadcast() {
		session.stopLive()
		session.running = false
		session.delegate = nil
		
		isBroadcasting = false
		
		UIApplication.shared.isIdleTimerDisabled = false
	}
	
	
	// MARK: -
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .black
		NotificationCenter.default.addObserver(self, selector: #selector(onDeviceRotated), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.shared.isIdleTimerDisabled = false
	}
	
	@objc func onDeviceRotated() {
//		session.videoCaptureSource
	}
	
}
