//
//  ViewController.swift
//  AlertBannerExample
//
//  Created by Steven Thompson on 2017-01-03.
//  Copyright © 2017 airg. All rights reserved.
//

import UIKit
import AlertBanner

enum SampleError: Error {
    case AlertBannerSampleError
}

enum DefaultMessages {
    static var warning: String = "You might be worried about this ¯\\_(ツ)_\\¯"
    static var success: String = "You did it!"
}

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    var isOfflineShowing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        alertBannerDisplayTime = 1.0
        offlineAlertBannerMessage = "You are offline"

        textField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func errorTapped(sender: UIButton) {
        if let customText = textField.text, !customText.isEmpty {
            AlertBanner.show(customText)
        } else {
            AlertBanner.show(SampleError.AlertBannerSampleError)
        }
    }

    @IBAction func warningTapped(sender: UIButton) {
        if let customText = textField.text, !customText.isEmpty {
            AlertBanner.show(customText, as: .warning)
        } else {
            AlertBanner.show(DefaultMessages.warning, as: .warning)
        }
    }

    @IBAction func successTapped(sender: UIButton) {
        if let customText = textField.text, !customText.isEmpty {
            AlertBanner.show(customText, as: .success)
        } else {
            AlertBanner.show(DefaultMessages.success, as: .success)
        }
    }

    @IBAction func offlineTapped(sender: UIButton) {
        if isOfflineShowing {
            AlertBanner.hideOfflineError()
        } else {
            AlertBanner.showOfflineError()
        }
        isOfflineShowing = !isOfflineShowing
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

