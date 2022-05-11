//
//  CallHistoryContactCellView.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import Cocoa

final class CallHistoryContactCellView: NSTableCellView {
    @IBOutlet private weak var labelField: NSTextField!

    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            switch backgroundStyle {
            case .normal, .raised, .lowered:
                if #available(macOS 10.14, *) {} else {
                    labelField.textColor = .secondaryLabelColor
                }
            case .emphasized:
                if #available(macOS 10.14, *) {} else {
                    labelField.textColor = .lightGray
                }
            @unknown default:
                break
            }
        }
    }
}
