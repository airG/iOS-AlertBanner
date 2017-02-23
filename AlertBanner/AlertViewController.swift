//
//  AlertViewController.swift
//  AlertBanner
//
//  Created by Steven Thompson on 2016-12-23.
//  Copyright © 2016 airg. All rights reserved.
//

import UIKit

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

/// Message to display when calling showOfflineError(). Provide your own NetworkOfflineErrorLabel in Localizable.strings
public var offlineAlertBannerMessage: String = NSLocalizedString("NetworkOfflineErrorLabel", tableName: "Localizable", bundle: Bundle(for: AlertBanner.self), value: "NetworkOfflineErrorLabel", comment: "NetworkOfflineErrorLabel")

/// How long the banner will stay visible.
public var alertBannerDisplayTime: TimeInterval = 4.0

/// How long the slide up/down will take.
public var alertBannerAnimationTime: TimeInterval = 0.4

/// Provide a handler if you want to log in a different way than default print()
public var customLog: ((_ message: String, _ level: AlertBannerLevel, _ file: String, _ line: Int)-> Void)?

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
            Log(message, level: .success, file: file, line: line)
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
            Log(error.localizedErrorMessage, level: .success, file: file, line: line)
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
        Log("AlertBanner hiding offline", level: .success, file: #file, line: #line)
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
        DispatchQueue.main.async {
            self.window.makeKeyAndVisible()

            switch style {
            case .error:
                self.errorVC.errorBackground.backgroundColor = alertBannerErrorBackgroundColor
            case .warning:
                self.errorVC.errorBackground.backgroundColor = alertBannerWarningBackgroundColor
            case .success:
                self.errorVC.errorBackground.backgroundColor = alertBannerSuccessBackgroundColor
            }

            // Reset Timer
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(timeInterval: alertBannerDisplayTime, target: self, selector: #selector(self.hide), userInfo: nil, repeats: false)

            if !self.visible {
                self.errorVC.errorTitle.text = title
                self.showError(true)
            } else {
                UIView.animate(withDuration: alertBannerAnimationTime, animations: {
                    self.errorVC.errorTitle.text = title
                })
            }
        }
    }

    @objc fileprivate func hide() {
        showError(false)
    }

    fileprivate func showOffline(visible vis: Bool) {
        DispatchQueue.main.async {
        if self.visible {
            self.hide()
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
    }

    fileprivate func showError(_ visible: Bool) {
        DispatchQueue.main.async {
            guard !self.offlineVisible else {
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

    fileprivate static func Log(_ message: String, level: AlertBannerLevel, file: String, line: Int) {
        if let customLog = customLog {
            customLog(message, level, file, line)
        } else {
            let singleFile: String
            if let f = file.components(separatedBy: "/").last {
                singleFile = f
            } else {
                singleFile = ""
            }

            let mes = "\(dateFormatter.string(from: NSDate() as Date)) <\(level)> \(singleFile):\(line) - \(message)"
            print(mes)
        }
    }

    fileprivate static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return df
    }()
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
