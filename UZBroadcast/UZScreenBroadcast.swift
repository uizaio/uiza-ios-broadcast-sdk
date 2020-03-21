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
	public var isMicrophoneEnabled: Bool {
		get {
			return screenRecorder.isMicrophoneEnabled
		}
		set {
			screenRecorder.isMicrophoneEnabled = newValue
		}
	}
	
	public var isCameraEnabled: Bool {
		get {
			return screenRecorder.isCameraEnabled
		}
		set {
			screenRecorder.isCameraEnabled = newValue
		}
	}
	
	public var cameraPreviewView: UIView? {
		return screenRecorder.cameraPreviewView
	}
	
	public var cameraPosition: RPCameraPosition {
		return screenRecorder.cameraPosition
	}
	
	public var isRecording: Bool {
		return screenRecorder.isRecording
	}
	
	let screenRecorder = RPScreenRecorder.shared()
	
	lazy open var session: LFLiveSession = {
		let audioConfiguration = LFLiveAudioConfiguration()
		let videoConfiguration = LFLiveVideoConfiguration()
		videoConfiguration.autorotate = false
		
		let result = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration, captureType: LFLiveCaptureTypeMask.inputMaskVideo)!
		return result
	}()
	
	private init() {
		
	}
	
	public func startBroadcast(broadcastURL: URL, completionHandler: ((Error?) -> Void)? = nil) {
		isBroadcasting = true
		
		let stream = LFLiveStreamInfo()
		stream.url = broadcastURL.absoluteString
		session.startLive(stream)
		
		screenRecorder.startCapture(handler: { [weak self] (sampleBuffer, bufferType, error) in
			guard let `self` = self else { return }
			self.session.pushVideo(sampleBuffer.imageBuffer)
		}, completionHandler: completionHandler)
	}
	
	public func stopBroadcast(handler: ((Error?) -> Void)? = nil) {
		session.stopLive()
		screenRecorder.stopCapture(handler: handler)
	}
	
}
