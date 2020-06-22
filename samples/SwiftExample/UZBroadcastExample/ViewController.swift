//
//  ViewController.swift
//  UZBroadcastExample
//
//  Created by Nam Kennic on 3/17/20.
//  Copyright © 2020 Uiza. All rights reserved.
//

import UIKit
import UZBroadcast

struct TableItem {
	var title: String
	var value: String
	var options: [String]
}

struct TableSection {
	var title: String
	var items: [TableItem]
}

enum TableSectionType: String {
	case videoResolution = "Resolution"
	case videoBitrate = "Bitrate"
	case videoFPS = "FPS"
	case audioBitrate = "Bitrate "
	case audioSampleRate = "SampleRate"
}

class ViewController: UIViewController {
	let tableView = UITableView(frame: .zero, style: .grouped)
	let startButton = UIButton(type: .system)
	
	var sections: [TableSection] = [] {
		didSet {
			tableView.reloadData()
		}
	}
	
	var videoResolution: UZVideoResolution = ._720
	var videoBitrate: UZVideoBitrate = ._3000
	var videoFPS: UZVideoFPS = ._30
	
	var audioBitrate: UZAudioBitRate = ._128Kbps
    var audioSampleRate: UZAudioSampleRate = ._44100Hz
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		startButton.setTitle("Start Broadcast", for: .normal)
		startButton.setTitle("Stop Broadcast", for: .selected)
		startButton.addTarget(self, action: #selector(onStart), for: .touchUpInside)
		
		tableView.delegate = self
		tableView.dataSource = self
		
//		squareView.backgroundColor = .purple
		
		view.addSubview(tableView)
		view.addSubview(startButton)
//		view.addSubview(squareView)
		
		updateValues()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let viewSize = view.bounds.size
		let buttonSize = CGSize(width: 120, height: 50)
		startButton.frame = CGRect(x: 10, y: viewSize.height - buttonSize.height - 20, width: viewSize.width - 20, height: buttonSize.height)
		tableView.frame = view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: buttonSize.height + 20, right: 0))
		
//		let squareSize = CGSize(width: 100, height: 100)
//		squareView.frame = CGRect(x: (viewSize.width - squareSize.width)/2, y: viewSize.height - squareSize.height - buttonSize.height - 50, width: squareSize.width, height: squareSize.height)
	}
	
	/*
	func startRotating() {
		squareView.layer.removeAllAnimations()
		let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
		rotate.duration = 3.0
		rotate.toValue = NSNumber(value: Double.pi * 2)
		rotate.repeatCount = .infinity
		rotate.isRemovedOnCompletion = false
		squareView.layer.add(rotate, forKey: "")
	}
	
	func stopRotating() {
		squareView.layer.removeAllAnimations()
	}
	*/
	
	@objc func onStart() {
		/*
		if #available(iOS 13.0, *) {
			if screenBroadcaster.isBroadcasting || startButton.isSelected {
				stopRotating()
				screenBroadcaster.stopBroadcast()
				startButton.isSelected = false
				return
			}
		}
		*/
		
		let alertController = UIAlertController(title: "Start broadcast", message: "Please enter your broadcast URL", preferredStyle: .alert)
		alertController.addTextField { (textField) in
			textField.text = UserDefaults.standard.string(forKey: "lastUrl")
			textField.placeholder = "URL"
			textField.keyboardType = .URL
			textField.returnKeyType = .done
		}
		alertController.addTextField { (textField) in
			textField.text = UserDefaults.standard.string(forKey: "laststreamKey")
			textField.placeholder = "streamKey"
			textField.keyboardType = .default
			textField.returnKeyType = .next
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			alertController.dismiss(animated: true, completion: nil)
		}))
		alertController.addAction(UIAlertAction(title: "Start Broadcast", style: .default, handler: { [weak self] (action) in
			guard let textFields = alertController.textFields else { return }
			guard let url = URL(string: textFields.first?.text ?? ""), let streamKey = textFields.last?.text else { return }
			self?.startBroadcasting(url: url, streamKey: streamKey)
			alertController.dismiss(animated: true, completion: nil)
		}))
		/*
		if #available(iOS 13.0, *) {
			alertController.addAction(UIAlertAction(title: "Screen Broadcast", style: .default, handler: { [weak self] (action) in
				guard let textFields = alertController.textFields else { return }
				guard let url = URL(string: textFields.first?.text ?? ""), let streamKey = textFields.last?.text else { return }
				self?.startScreenBroadcasting(url: url, streamKey: streamKey)
				alertController.dismiss(animated: true, completion: nil)
			}))
		}
		*/
		present(alertController, animated: true, completion: nil)
	}
	
	func updateValues() {
		sections = [TableSection(title: "Video", items: [TableItem(title: TableSectionType.videoResolution.rawValue, value: videoResolution.toString(), options: UZVideoResolution.allCases.compactMap({ return $0.toString() })),
														 TableItem(title: TableSectionType.videoBitrate.rawValue, value: videoBitrate.toString(), options: UZVideoBitrate.allCases.compactMap({ return $0.toString() })),
														 TableItem(title: TableSectionType.videoFPS.rawValue, value: videoFPS.toString(), options: UZVideoFPS.allCases.compactMap({ return $0.toString() }))]),
					
					TableSection(title: "Audio", items: [TableItem(title: TableSectionType.audioBitrate.rawValue, value: audioBitrate.toString(), options: UZAudioBitRate.allCases.compactMap({ return $0.toString() })),
														 TableItem(title: TableSectionType.audioSampleRate.rawValue, value: audioSampleRate.toString(), options: UZAudioSampleRate.allCases.compactMap({ return $0.toString() }))])]
	}
	
	func startBroadcasting(url: URL, streamKey: String) {
		UserDefaults.standard.set(url.absoluteString, forKey: "lastUrl")
		UserDefaults.standard.set(streamKey, forKey: "laststreamKey")
		
		let config = UZBroadcastConfig(cameraPosition: .front, videoResolution: videoResolution, videoBitrate: videoBitrate, videoFPS: videoFPS, audioBitrate: audioBitrate, audioSampleRate: audioSampleRate, adaptiveBitrate: true, autoRotate: false)
		let broadcastViewController = MyBroadcastViewController()
		broadcastViewController.prepareForBroadcast(config: config).delegate = self
//		broadcastViewController.session.beautyFace = true
		broadcastViewController.modalPresentationStyle = .fullScreen
		
		present(broadcastViewController, animated: false) {
			broadcastViewController.startBroadcast(broadcastURL: url, streamKey: streamKey)
		}
	}
	
	@available(iOS 13.0, *)
	func startScreenBroadcasting(url: URL, streamKey: String) {
//		startRotating()
		
		UserDefaults.standard.set(url.absoluteString, forKey: "lastUrl")
		UserDefaults.standard.set(streamKey, forKey: "laststreamKey")
		
		startButton.isSelected = true
		let config = UZBroadcastConfig(cameraPosition: .back, videoResolution: videoResolution, videoBitrate: videoBitrate, videoFPS: videoFPS, audioBitrate: audioBitrate, audioSampleRate: audioSampleRate, adaptiveBitrate: true, autoRotate: false)
		let broadcaster = UZScreenBroadcast()
		broadcaster.prepareForBroadcast(config: config).delegate = self
		broadcaster.isCameraEnabled = false
		broadcaster.isMicrophoneEnabled = false
		broadcaster.startBroadcast(broadcastURL: url, streamKey: streamKey)
	}
	
	func switchValue(index: Int, for option: TableItem) {
		print("Switch \(option) index:\(index)")
		
		if option.title == TableSectionType.videoResolution.rawValue {
			videoResolution = UZVideoResolution.allCases[index]
		}
		else if option.title == TableSectionType.videoBitrate.rawValue {
			videoBitrate = UZVideoBitrate.allCases[index]
		}
		else if option.title == TableSectionType.videoFPS.rawValue {
			videoFPS = UZVideoFPS.allCases[index]
		}
		else if option.title == TableSectionType.audioBitrate.rawValue {
			audioBitrate = UZAudioBitRate.allCases[index]
		}
		else if option.title == TableSectionType.audioSampleRate.rawValue {
			audioSampleRate = UZAudioSampleRate.allCases[index]
		}
		
		updateValues()
	}
	
	func showOptions(item: TableItem) {
		let alertController = UIAlertController(title: item.title, message: nil, preferredStyle: .actionSheet)
		item.options.forEach { (title) in
			alertController.addAction(UIAlertAction(title: title, style: .default, handler: { [weak self] (action) in
				if let index = item.options.firstIndex(of: action.title ?? "") {
					self?.switchValue(index: index, for: item)
				}
			}))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			alertController.dismiss(animated: true, completion: nil)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let item = sections[indexPath.section].items[indexPath.row]
		cell.textLabel?.font = .systemFont(ofSize: 14, weight: .bold)
		cell.detailTextLabel?.font = .systemFont(ofSize: 14, weight: .regular)
		cell.textLabel?.text = item.title
		cell.detailTextLabel?.text = item.value
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		showOptions(item: sections[indexPath.section].items[indexPath.row])
	}
	
}

extension ViewController: UZBroadcastSessionDelegate {
	
	func broadcastSession(_ session: UZBroadcastSession?, debugInfo: UZBroadcastDebug?) {
		print("UZBroadcastState: \(String(describing: debugInfo))")
	}
	
	func broadcastSession(_ session: UZBroadcastSession?, errorCode: UZSocketErrorCode) {
		print("UZBroadcastState errorCode: \(String(describing: errorCode))")
	}
	
	func broadcastSession(_ session: UZBroadcastSession?, broadcastStateDidChange state: UZBroadcastState) {
		print("UZBroadcastState: \(String(describing: state.rawValue))")
	}
	
}
