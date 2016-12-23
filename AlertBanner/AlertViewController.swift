//
//  AlertViewController.swift
//  AlertBanner
//
//  Created by Steven Thompson on 2016-12-23.
//  Copyright © 2016 airg. All rights reserved.
//

import UIKit
import airGiOSTools

/// Font to use on the label in the alert banner.
public var alertBannerFont: UIFont = .systemFont(ofSize: 14.0)

/// Text color, will be used on all three banner backgrounds.
public var alertBannerTextColor: UIColor = .white

/// Background colour for level: .error
public var alertBannerErrorBackgroundColor: UIColor = .red

/// Background colour for level: .warning
public var alertBannerWarningBackgroundColor: UIColor = .lightGray

/// Background colour for level: .success
public var alertBannerSuccessBackgroundColor: UIColor = .green

/// Message to display when calling showOfflineError()
public var offlineAlertBannerMessage: String = NSLocalizedString("NetworkOfflineErrorLabel", comment: "")

/// How long the banner will stay visible.
public var alertBannerDisplayTime: TimeInterval = 4.0

/// How long the slide up/down will take.
public var alertBannerAnimationTime: TimeInterval = 0.4

public enum AlertBannerLevel {
    case error, warning, success
}

open class AlertBanner: NSObject {
    /// Use the manager singleton to display errors
    open static var manager: AlertBanner = AlertBanner()

    /// Shows an alert banner dropping from the top of the screen.
    ///
    /// - Parameters:
    ///   - message: String message to display in the banner.
    ///   - level: `AlertBannerLevel` of the alert, defaults to .`error`.
    ///   - file: Automatically gets file where Alert is being presented, don't provide this.
    ///   - line: Automatically gets line where Alert is being presented, don't provide this.
    ///   - onTap: Closure to execute on tapping the banner
    open class func show(_ message: String, as level: AlertBannerLevel = .error, file: String = #file, line: Int = #line, onTap:(()->Void)? = nil) {
        switch level {
        case .error:
            Log(message, level: .error, file: file, line: line)
            manager.show(title: message, style: .error, onTap: onTap)
        case .warning:
            Log(message, level: .warning, file: file, line: line)
            manager.show(title: message, style: .warning, onTap: onTap)
        case .success:
            Log(message, level: .info, file: file, line: line)
            manager.show(title: message, style: .success, onTap: onTap)
        }
    }

    /// Shows an alert banner dropping from the top of the screen.
    ///
    /// - Parameters:
    ///   - error: Error to display in the banner, using the `localizedErrorMessage` property of the error.
    ///   - level: `AlertBannerLevel` of the alert, defaults to .`error`.
    ///   - file: Automatically gets file where Alert is being presented, don't provide this.
    ///   - line: Automatically gets line where Alert is being presented, don't provide this.
    ///   - onTap: Closure to execute on tapping the banner
    open class func show(_ error: Error, as level: AlertBannerLevel = .error, file: String = #file, line: Int = #line, onTap:(()->Void)? = nil) {
        switch level {
        case .error:
            Log(error.localizedErrorMessage, level: .error, file: file, line: line)
            manager.show(title: error.localizedErrorMessage, style: .error, onTap: onTap)
        case .warning:
            Log(error.localizedErrorMessage, level: .warning, file: file, line: line)
            manager.show(title: error.localizedErrorMessage, style: .warning, onTap: onTap)
        case .success:
            Log(error.localizedErrorMessage, level: .info, file: file, line: line)
            manager.show(title: error.localizedErrorMessage, style: .success, onTap: onTap)
        }
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
        timer = Timer.scheduledTimer(timeInterval: alertBannerDisplayTime, target: self, selector: #selector(hide), userInfo: nil, repeats: false)

        if !visible {
            errorVC.errorTitle.text = title
            showError(true)
        } else {
            UIView.animate(withDuration: alertBannerAnimationTime, animations: {
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

        UIView.animate(withDuration: alertBannerAnimationTime, animations: {
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

        UIView.animate(withDuration: alertBannerAnimationTime, animations: {
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

        errorTitle.textColor = alertBannerTextColor
        errorTitle.font = alertBannerFont
        errorTitle.numberOfLines = 0
        errorTitle.textAlignment = .center

        offlineErrorBackground.backgroundColor = alertBannerErrorBackgroundColor

        offlineErrorTitle.textColor = alertBannerTextColor
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
