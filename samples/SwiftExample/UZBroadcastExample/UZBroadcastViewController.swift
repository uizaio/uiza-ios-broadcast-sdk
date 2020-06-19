//
//  UZLiveView.swift
//  UizaSDK
//
//  Created by Nam Kennic on 8/28/18.
//  Copyright © 2018 Nam Kennic. All rights reserved.
//

import UIKit
import UZBroadcast
import ReplayKit

/**
This class helps you to initialize a livestream session
*/
open class UZBroadcastViewController: UIViewController {
	/// `true` if broadcasting
	public fileprivate(set)var isBroadcasting = false
	/// Current broadcast configuration
	public fileprivate(set) var config: UZBroadcastConfig!
	/// Current live session
	lazy var session: UZLiveSession = {
		let audioConfiguration = UZAudioConfiguration.defaultConfiguration(for: .veryHigh)!
		audioConfiguration.numberOfChannels = 2
		audioConfiguration.audioBitrate = config.audioBitrate
		audioConfiguration.audioSampleRate = config.audioSampleRate
		
		let orientation = config.orientation ?? UIApplication.shared.interfaceOrientation ?? .portrait
		let videoConfiguration = UZVideoConfiguration.defaultConfiguration(for: config.videoResolution.videoQuality, outputImageOrientation: orientation, encode: false)!
		videoConfiguration.outputImageOrientation = orientation
		videoConfiguration.sessionPreset = config.videoResolution.sessionPreset
		videoConfiguration.videoFrameRate = config.videoFPS.rawValue
		videoConfiguration.videoMaxFrameRate = config.videoFPS.rawValue
		videoConfiguration.videoMinFrameRate = config.videoFPS.rawValue
		videoConfiguration.videoBitRate = config.videoBitrate.rawValue
		videoConfiguration.videoMaxBitRate = config.videoBitrate.rawValue
		videoConfiguration.videoMinBitRate = config.videoBitrate.rawValue/2
		videoConfiguration.videoSize = config.videoResolution.videoSize
		videoConfiguration.videoMaxKeyframeInterval = config.videoFPS.rawValue * 2
		videoConfiguration.autorotate = false
		
		let result = UZLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)!
		result.adaptiveBitrate = config.adaptiveBitrate
		result.captureDevicePosition = config.cameraPosition
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
	
	/**
	Request accessing for video
	*/
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
		case AVAuthorizationStatus.restricted: break
		@unknown default:break
		}
	}
	
	/**
	Request accessing for audio
	*/
	open func requestAccessForAudio() {
		let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
		switch status {
		case AVAuthorizationStatus.notDetermined:
			AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (_) in })
			
		case AVAuthorizationStatus.authorized: break
		case AVAuthorizationStatus.denied: break
		case AVAuthorizationStatus.restricted: break
		@unknown default: break
		}
	}
	
	/**
	Always call this first to prepare broadcasting with a configuration
	- parameter config: Broadcast configuration
	*/
	@discardableResult
	public func prepareForBroadcast(config: UZBroadcastConfig) -> UZLiveSession {
		self.config = config
		return session
	}
	
	/**
	Start broadcasting
	- parameter broadcastURL: `URL` of broadcast
	- parameter streamKey: Stream Key
	*/
	public func startBroadcast(broadcastURL: URL, streamKey: String) {
		isBroadcasting = true
		
		let stream = UZStreamInfo()
		stream.url = broadcastURL.appendingPathComponent(streamKey).absoluteString
		session.startLive(stream)
		
		UIApplication.shared.isIdleTimerDisabled = true
	}
	
	/**
	Stop broadcasting
	*/
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
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		requestAccessForVideo()
		requestAccessForAudio()
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.shared.isIdleTimerDisabled = false
	}
	
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
