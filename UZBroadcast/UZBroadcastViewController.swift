//
//  UZLiveView.swift
//  UizaSDK
//
//  Created by Nam Kennic on 8/28/18.
//  Copyright © 2018 Nam Kennic. All rights reserved.
//

import UIKit
import LFLiveKit_

public enum UZVideoResolution {
	case _360
	case _480
	case _720
	case _1080
	
	var videoSize: CGSize {
		switch self {
		case ._360:
			return CGSize(width: 360, height: 640)
		case ._480:
			return CGSize(width: 480, height: 640)
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
}

public enum UZVideoBitrate: UInt {
	case _500 = 500
	case _1000 = 1000
	case _1500 = 1500
	case _2000 = 2000
	case _3000 = 3000
	case _4000 = 4000
	case _5000 = 5000
	case _6000 = 6000
}

public enum UZVideoFPS: UInt {
	case _30 = 30
	case _60 = 60
}

public enum UZAudioBitrate: UInt {
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
}

public enum UZAudioSampleRate: UInt {
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
}

public struct UZBroadcastConfig {
	public var cameraPosition: AVCaptureDevice.Position
	public var videoResolution: UZVideoResolution
	public var videoBitrate: UZVideoBitrate
	public var videoFPS: UZVideoFPS
	public var audioBitrate: UZAudioBitrate
	public var audioSampleRate: UZAudioSampleRate
	public var adaptiveBitrate: Bool
	public var orientation: UIInterfaceOrientation? = .portrait
}

open class UZBroadcastViewController: UIViewController {
	public var isEncoded = true
	public fileprivate(set)var isBroadcasting = false
	
	public var saveLocalVideo: Bool {
		get {
			return session.saveLocalVideo
		}
		set {
			session.saveLocalVideo = newValue
		}
	}
	
	public var localVideoURL: URL? {
		get {
			return session.saveLocalVideoPath
		}
		set {
			session.saveLocalVideoPath = newValue
		}
	}
	
	public var config: UZBroadcastConfig!
	
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
		videoConfiguration.outputImageOrientation = config.orientation ?? .portrait
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
		return UIDevice.current.userInterfaceIdiom == .pad
	}
	
	open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
	}
	
	open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return UIDevice.current.userInterfaceIdiom == .pad ? UIApplication.shared.statusBarOrientation : .portrait
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
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.shared.isIdleTimerDisabled = false
	}
	
}
