//
//  UZBroadcastConfig.swift
//  UZBroadcast
//
//  Created by Nam Kennic on 3/26/20.
//  Copyright © 2020 Uiza. All rights reserved.
//

import UIKit
import UZBroadcast

public enum UZVideoResolution: CaseIterable {
	case _360
	case _480
	case _720
	case _1080
	
	/// Convert to CGSize
	public var videoSize: CGSize {
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
	
	internal var sessionPreset: UZVideoSessionPreset {
		switch self {
		case ._360:
			return .preset360x640
		case ._480:
			return .preset480x854
		case ._720:
			return .preset720x1280
		case ._1080:
			return .preset1920x1080
		}
	}
	
	internal var videoQuality: UZVideoQuality {
		switch self {
		case ._360:
			return .SD_360
		case ._480:
			return .SD_480
		case ._720:
			return .HD_720
		case ._1080:
			return .fullHD_1080
		}
	}
	
	/// Convert to readable string
	public func toString() -> String {
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

extension UZAudioBitRate {
    static var allCases: [UZAudioBitRate] {
        var allCases: [UZAudioBitRate] = []
        switch (UZAudioBitRate._32Kbps) {
            case ._32Kbps: allCases.append(._32Kbps); fallthrough
            case ._64Kbps: allCases.append(._64Kbps); fallthrough
            case ._96Kbps: allCases.append(._96Kbps); fallthrough
            case ._128Kbps: allCases.append(._128Kbps)
            @unknown default:
                break;
        }
        return allCases
    }
    
    public func toString() -> String {
        return "\(self.rawValue/1000) Kbps"
    }
}

extension UZAudioSampleRate {
   static var allCases: [UZAudioSampleRate] {
          var allCases: [UZAudioSampleRate] = []
    switch (UZAudioSampleRate._16000Hz) {
            case ._16000Hz: allCases.append(._16000Hz); fallthrough
            case ._44100Hz: allCases.append(._44100Hz); fallthrough
            case ._48000Hz: allCases.append(._48000Hz)
            @unknown default:
                break;
          }
          return allCases
      }
    public func toString() -> String {
          return "\(self.rawValue/1000) Kbps"
      }
}


public enum UZVideoBitrate: UInt, CaseIterable {
	case _500 = 500_000
	case _1000 = 1_000_000
	case _1500 = 1_500_000
	case _2000 = 2_000_000
	case _3000 = 3_000_000
	case _4000 = 4_000_000
	case _5000 = 5_000_000
	case _6000 = 6_000_000
	
	/// Convert to readable string
	public func toString() -> String {
		return "\(self.rawValue/1000) Kbps"
	}
}

public enum UZVideoFPS: UInt, CaseIterable {
	case _30 = 30
	case _60 = 60
	
	/// Convert to readable string
	public func toString() -> String {
		return "\(self.rawValue) fps"
	}
}


public struct UZBroadcastConfig {
	public var cameraPosition: AVCaptureDevice.Position
	public var videoResolution: UZVideoResolution
	public var videoBitrate: UZVideoBitrate
	public var videoFPS: UZVideoFPS
	public var audioBitrate: UZAudioBitRate
	public var audioSampleRate: UZAudioSampleRate
	public var adaptiveBitrate: Bool
	public var orientation: UIInterfaceOrientation?
	public var autoRotate: Bool?
	
	public init(cameraPosition: AVCaptureDevice.Position, videoResolution: UZVideoResolution, videoBitrate: UZVideoBitrate, videoFPS: UZVideoFPS, audioBitrate: UZAudioBitRate, audioSampleRate: UZAudioSampleRate, adaptiveBitrate: Bool, orientation: UIInterfaceOrientation? = nil, autoRotate: Bool? = nil) {
		self.cameraPosition = cameraPosition
		self.videoResolution = videoResolution
		self.videoBitrate = videoBitrate
		self.videoFPS = videoFPS
		self.audioBitrate = audioBitrate
		self.audioSampleRate = audioSampleRate
		self.adaptiveBitrate = adaptiveBitrate
		self.orientation = orientation
		self.autoRotate = autoRotate
	}
}
