//
//  UZScreenBroadcast.swift
//  UZBroadcast
//
//  Created by Nam Kennic on 3/21/20.
//  Copyright © 2020 Uiza. All rights reserved.
//

import UIKit
import LFLiveKit_
import ReplayKit

/**
This class helps you to initialize a screen broadcast session
*/
@available(iOS 13.0, *)
public class UZScreenBroadcast {
	/// Singleton instance
	static public let shared = UZScreenBroadcast()
	
	/// `true` if broadcasting
	public fileprivate(set)var isBroadcasting = false
	
	@available(iOS 13.0, *)
	/// Turn on or off microphone
	public var isMicrophoneEnabled: Bool {
		get {
			return screenRecorder.isMicrophoneEnabled
		}
		set {
			screenRecorder.isMicrophoneEnabled = newValue
		}
	}
	
	@available(iOS 13.0, *)
	/// Turn on or off camera
	public var isCameraEnabled: Bool {
		get {
			return screenRecorder.isCameraEnabled
		}
		set {
			screenRecorder.isCameraEnabled = newValue
		}
	}
	
	@available(iOS 13.0, *)
	/// Current camera preview view
	public var cameraPreviewView: UIView? {
		return screenRecorder.cameraPreviewView
	}
	
	@available(iOS 13.0, *)
	/// Current camera position
	public var cameraPosition: RPCameraPosition {
		return screenRecorder.cameraPosition
	}
	
	@available(iOS 13.0, *)
	/// `true` if the screen is recording
	public var isRecording: Bool {
		return screenRecorder.isRecording
	}
	
	/// Current broadcast configuration
	public fileprivate(set) var config: UZBroadcastConfig!
	let screenRecorder = RPScreenRecorder.shared()
	
	/// Current live session
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
		
		let result = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration, captureType: LFLiveCaptureTypeMask.inputMaskAll)!
		result.adaptiveBitrate = config.adaptiveBitrate
		return result
	}()
	
	private init() {}
	
	/**
	Always call this first to prepare broadcasting with a configuration
	- parameter config: Broadcast configuration
	*/
	public func prepareForBroadcast(withConfig config: UZBroadcastConfig) {
		self.config = config
	}
	
	/**
	Start screen broadcasting
	- parameter broadcastURL: `URL` of broadcast
	- parameter streamId: `id` of broadcast
	- parameter completionHandler: Block called when completed, returns `Error` if occured
	*/
	public func startBroadcast(broadcastURL: URL, streamId: String, completionHandler: ((Error?) -> Void)? = nil) {
		isBroadcasting = true
		
		let stream = LFLiveStreamInfo()
		stream.streamId = streamId
		stream.url = broadcastURL.absoluteString
		session.startLive(stream)
		
		screenRecorder.cameraPosition = config.cameraPosition == .front ? .front : .back
		screenRecorder.startCapture(handler: { [weak self] (sampleBuffer, bufferType, error) in
			guard let `self` = self else { return }
			if bufferType == .audioMic || bufferType == .audioApp {
				if let data = try? sampleBuffer.dataBuffer?.dataBytes() {
					self.session.pushAudio(data)
				}
			}
			else {
				self.session.pushVideo(sampleBuffer.imageBuffer)
			}
		}, completionHandler: completionHandler)
	}
	
	/**
	Stop screen broadcasting
	- parameter handler: Block called when completed, returns `Error` if occured
	*/
	public func stopBroadcast(handler: ((Error?) -> Void)? = nil) {
		session.stopLive()
		screenRecorder.stopCapture(handler: handler)
		isBroadcasting = false
	}
	
}
