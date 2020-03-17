//
//  ViewController.swift
//  UZBroadcastExample
//
//  Created by Nam Kennic on 3/17/20.
//  Copyright © 2020 Uiza. All rights reserved.
//

import UIKit
import LFLiveKit_

class ViewController: UZBroadcastViewController {
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let config = UZBroadcastConfig(cameraPosition: .front, videoResolution: ._720, videoBitrate: ._3000, videoFPS: ._30, audioBitrate: ._128Kbps, audioSampleRate: ._44_1khz, adaptiveBitrate: true)
		prepareForBroadcast(withConfig: config)
		session.delegate = self
		startBroadcast(broadcastURL: URL(string: "https://your_url_here.com")!)
	}
	
}

extension ViewController: LFLiveSessionDelegate {
	
	func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
		print("LFLiveState: \(String(describing: debugInfo))")
	}
	
	func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
		print("LFLiveState errorCode: \(String(describing: errorCode))")
	}
	
	func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
		print("LFLiveState: \(String(describing: state.rawValue))")
	}
	

}
