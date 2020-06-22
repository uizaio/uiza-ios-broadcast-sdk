//
//  MyBroadcastViewController.swift
//  UZBroadcastExample
//
//  Created by Nam Kennic on 3/19/20.
//  Copyright © 2020 Uiza. All rights reserved.
//

import UIKit

class MyBroadcastViewController: UZBroadcastViewController {
	let closeButton = UIButton()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		closeButton.titleLabel?.font = .monospacedDigitSystemFont(ofSize: 18, weight: .medium)
		closeButton.setTitle("X", for: .normal)
		closeButton.addTarget(self, action: #selector(askForClose), for: .touchUpInside)
		closeButton.showsTouchWhenHighlighted = true
		view.addSubview(closeButton)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let viewSize = view.bounds.size
		let buttonSize = CGSize(width: 33, height: 33)
		closeButton.frame = CGRect(x: viewSize.width - buttonSize.width - 15, y: 30, width: buttonSize.width, height: buttonSize.height)
	}
	
	@objc func askForClose() {
		let alertController = UIAlertController(title: "Stop Broadcast?", message: nil, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			alertController.dismiss(animated: true, completion: nil)
		}))
		alertController.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { [weak self] (action) in
			alertController.dismiss(animated: false, completion: nil)
			self?.stopBroadcast()
			self?.dismiss(animated: true, completion: nil)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
}
