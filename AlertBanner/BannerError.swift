//
//  BannerError.swift
//  AlertBanner
//
//  Created by Steven Thompson on 2016-12-23.
//  Copyright © 2016 airg. All rights reserved.
//

import Foundation

enum BannerError {
    case `default`
}

extension Error {
    var localizedErrorMessage: String {
        return NSLocalizedString(String(describing: self), comment: "")
    }
}
