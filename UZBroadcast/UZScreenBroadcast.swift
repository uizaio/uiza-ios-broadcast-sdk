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

@available(iOS 13.0, *)
public class UZScreenBroadcast {
	static public let shared = UZScreenBroadcast()
	
	public fileprivate(set)var isBroadcasting = false
	
	@available(iOS 13.0, *)
	public var isMicrophoneEnabled: Bool {
		get {
			return screenRecorder.isMicrophoneEnabled
		}
		set {
			screenRecorder.isMicrophoneEnabled = newValue
		}
	}
	
	@available(iOS 13.0, *)
	public var isCameraEnabled: Bool {
		get {
			return screenRecorder.isCameraEnabled
		}
		set {
			screenRecorder.isCameraEnabled = newValue
		}
	}
	
	@available(iOS 13.0, *)
	public var cameraPreviewView: UIView? {
		return screenRecorder.cameraPreviewView
	}
	
	@available(iOS 13.0, *)
	public var cameraPosition: RPCameraPosition {
		return screenRecorder.cameraPosition
	}
	
	@available(iOS 13.0, *)
	public var isRecording: Bool {
		return screenRecorder.isRecording
	}
	
	public fileprivate(set) var config: UZBroadcastConfig!
	let screenRecorder = RPScreenRecorder.shared()
	
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
	
	private init() {
		
	}
	
	public func prepareForBroadcast(withConfig config: UZBroadcastConfig) {
		self.config = config
	}
	
	public func startBroadcast(broadcastURL: URL, streamId: String, completionHandler: ((Error?) -> Void)? = nil) {
		isBroadcasting = true
		
		let stream = LFLiveStreamInfo()
		stream.streamId = streamId
		stream.url = broadcastURL.absoluteString
		session.startLive(stream)
		
		screenRecorder.startCapture(handler: { [weak self] (sampleBuffer, bufferType, error) in
			guard let `self` = self else { return }
			if bufferType == .audioMic || bufferType == .audioApp {
				self.session.pushAudio(try? sampleBuffer.dataBuffer?.dataBytes())
			}
			else {
				self.session.pushVideo(sampleBuffer.imageBuffer)
			}
		}, completionHandler: completionHandler)
	}
	
	public func stopBroadcast(handler: ((Error?) -> Void)? = nil) {
		session.stopLive()
		screenRecorder.stopCapture(handler: handler)
		isBroadcasting = false
	}
	
}
