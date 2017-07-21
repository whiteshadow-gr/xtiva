/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Extension

extension UIColor {
    
    // MARK: - Staticly defined colors
    
    // swiftlint:disable object_literal
    static let toolbarColor: UIColor = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    static let teal: UIColor = UIColor(red: 0 / 255, green: 156 / 255, blue: 216 / 255, alpha: 1)
    static let tealDark: UIColor = UIColor(red: 0 / 255, green: 130 / 255, blue: 200 / 255, alpha: 1)
    static let tealLight: UIColor = UIColor(red: 35 / 255, green: 190 / 255, blue: 241 / 255, alpha: 1)
    static let rumpelLightGray: UIColor = UIColor(red: 100 / 255, green: 100 / 255, blue: 105 / 255, alpha: 1)
    static let rumpelDarkGray: UIColor = UIColor(red: 88 / 255, green: 88 / 255, blue: 90 / 255, alpha: 1)
    static let rumpelLighterDarkGray: UIColor = UIColor(red: 110 / 255, green: 110 / 255, blue: 117 / 255, alpha: 1)
    static let rumpelVeryLightGray: UIColor = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 1)
    
    static let onSwitchTintColor: UIColor = UIColor(red: 0 / 255, green: 156 / 255, blue: 216 / 255, alpha: 1)
    // swiftlint:enable object_literal
    
    // MARK: - Methods
    
    /**
     Returns an UIColor object from a RGB value
     
     - parameter rgbValue: The rgb value as UInt
     
     - returns: A UIColor based on the rgbValue
     */
    public class func fromRGB(_ rgbValue: UInt) -> UIColor {
        
        return self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
