//
//  AlertViewController.swift
//  AlertBanner
//
//  Created by Steven Thompson on 2016-12-23.
//  Copyright © 2016 airg. All rights reserved.
//

import UIKit
import airGiOSTools

public var alertBannerFont: UIFont = .systemFont(ofSize: 14.0)
public var alertBannerErrorBackgroundColor: UIColor = .red
public var alertBannerWarningBackgroundColor: UIColor = .lightGray
public var alertBannerSuccessBackgroundColor: UIColor = .green
public var offlineAlertBannerMessage: String = NSLocalizedString("NetworkOfflineErrorLabel", comment: "")

open class AlertBanner: NSObject {
    /// Use the manager singleton to display errors
    open static var manager: AlertBanner = AlertBanner()

    /**
     Shows an error dropping from the top of the screen, with a 4 second timeout.

     - parameter title: Error message to display
     - parameter onTap: Do something when the user taps the error
     */
    open class func showError(title: String, file: String = #file, line: Int = #line, onTap:(()->Void)? = nil) {
        Log(title, level: .error, file: file, line: line)
        manager.show(title: title, style: .error, onTap: onTap)
    }

    /**
     Shows an error dropping from the top of the screen, with a 4 second timeout.

     - parameter title: Error message to display
     - parameter onTap: Do something when the user taps the error
     */
    open class func showError(error: Error, file: String = #file, line: Int = #line, onTap:(()->Void)? = nil) {
        Log(error, level: .error, file: file, line: line)
        manager.show(title: error.localizedErrorMessage, style: .error, onTap: onTap)
    }

    /**
     Shows an orange warning dropping from the top of the screen, with a 4 second timeout.

     - parameter title: Warning message to display
     - parameter onTap: Do something when the user taps the error
     */
    open class func showWarning(title: String, file: String = #file, line: Int = #line, onTap:(()->Void)? = nil) {
        Log(title, level: .warning, file: file, line: line)
        manager.show(title: title, style: .warning, onTap: onTap)
    }

    /**
     Shows a green message dropping from the top of the screen, with a 4 second timeout.

     - parameter title: Message to display
     - parameter onTap: Do something when the user taps the error
     */
    open class func showSuccess(title: String, file: String = #file, line: Int = #line, onTap:(()->Void)? = nil) {
        Log(title, level: .info, file: file, line: line)
        manager.show(title: title, style: .success, onTap: onTap)
    }

    /**
     Hide the error immediately
     */
    open class func hide() {
        AlertBanner.manager.showError(false)
    }

    open class func showOfflineError() {
        Log("AlertBanner showing offline", level: .error, file: #file, line: #line)
        AlertBanner.manager.showOffline(visible: true)
    }

    open class func hideOfflineError() {
        Log("AlertBanner hiding offline", level: .info, file: #file, line: #line)
        AlertBanner.manager.showOffline(visible: false)
    }

    //MARK:- Private Implementation
    fileprivate let displayTime: TimeInterval = 3.0
    fileprivate let animationTime: TimeInterval = 0.4

    fileprivate let window: UIWindow = {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.backgroundColor = .clear
        win.windowLevel = UIWindowLevelStatusBar+1
        win.isUserInteractionEnabled = false
        return win
    }()

    fileprivate let errorVC: AlertViewController = AlertViewController(nibName: "AlertViewController", bundle: Bundle(for: AlertViewController.self))

    fileprivate var timer: Timer?

    fileprivate var visible: Bool = false
    fileprivate var offlineVisible: Bool = false

    fileprivate override init() {
        window.rootViewController = errorVC
    }

    fileprivate enum AlertStyle {
        case error, warning, success
    }
    /**
     Only for internal use
     */
    fileprivate func show(title: String, style: AlertStyle, onTap:(()->Void)? = nil) {
        window.makeKeyAndVisible()

        switch style {
        case .error:
            errorVC.errorBackground.backgroundColor = alertBannerErrorBackgroundColor
        case .warning:
            errorVC.errorBackground.backgroundColor = alertBannerWarningBackgroundColor
        case .success:
            errorVC.errorBackground.backgroundColor = alertBannerSuccessBackgroundColor
        }

        // Reset Timer
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: displayTime, target: self, selector: #selector(hide), userInfo: nil, repeats: false)

        if !visible {
            errorVC.errorTitle.text = title
            showError(true)
        } else {
            UIView.animate(withDuration: animationTime, animations: {
                self.errorVC.errorTitle.text = title
            })
        }
    }

    @objc fileprivate func hide() {
        showError(false)
    }

    fileprivate func showOffline(visible vis: Bool) {
        if visible {
            hide()
        }

        self.window.makeKeyAndVisible()
        self.window.isHidden = false

        UIView.animate(withDuration: animationTime, animations: {
            if vis {
                self.errorVC.offlineVisibleConstraint.priority = UILayoutPriorityDefaultHigh
                self.errorVC.offlineHiddenConstraint.priority = UILayoutPriorityDefaultLow
            } else {
                self.errorVC.offlineVisibleConstraint.priority = UILayoutPriorityDefaultLow
                self.errorVC.offlineHiddenConstraint.priority = UILayoutPriorityDefaultHigh
            }
            self.errorVC.view.layoutIfNeeded()
        }, completion: { completed in
            if completed && !vis {
                self.window.isHidden = true
                self.offlineVisible = false
            } else {
                self.offlineVisible = true
            }
        })
    }

    fileprivate func showError(_ visible: Bool) {
        guard !offlineVisible else {
            return
        }

        self.window.isHidden = false

        UIView.animate(withDuration: animationTime, animations: {
            if visible {
                self.errorVC.visibleConstraint.priority = UILayoutPriorityDefaultHigh
                self.errorVC.hiddenConstraint.priority = UILayoutPriorityDefaultLow
            } else {
                self.errorVC.visibleConstraint.priority = UILayoutPriorityDefaultLow
                self.errorVC.hiddenConstraint.priority = UILayoutPriorityDefaultHigh
            }
            self.errorVC.view.layoutIfNeeded()
        }, completion: { (completed) in
            if completed && !visible {
                self.window.isHidden = true
                self.timer?.invalidate()
                self.timer = nil
                self.visible = false
            } else {
                self.visible = true
            }
        })
    }
}

fileprivate class AlertViewController: UIViewController {
    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var errorBackground: UIView!
    @IBOutlet weak var hiddenConstraint: NSLayoutConstraint!
    @IBOutlet weak var visibleConstraint: NSLayoutConstraint!

    @IBOutlet weak var offlineErrorTitle: UILabel!
    @IBOutlet weak var offlineErrorBackground: UIView!
    @IBOutlet weak var offlineVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var offlineHiddenConstraint: NSLayoutConstraint!

    var onTap:(()->Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        errorBackground.isUserInteractionEnabled = true
        errorBackground.backgroundColor = alertBannerErrorBackgroundColor

        errorTitle.textColor = .white
        errorTitle.font = alertBannerFont
        errorTitle.numberOfLines = 0
        errorTitle.textAlignment = .center

        offlineErrorBackground.backgroundColor = alertBannerErrorBackgroundColor

        offlineErrorTitle.textColor = .white
        offlineErrorTitle.font = alertBannerFont
        offlineErrorTitle.numberOfLines = 0
        offlineErrorTitle.textAlignment = .center
        offlineErrorTitle.text = offlineAlertBannerMessage

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapped))
        errorBackground.addGestureRecognizer(tapGR)
    }

    func tapped() {
        AlertBanner.manager.showError(false)

        if let onTap = onTap {
            onTap()
        }
    }
}
