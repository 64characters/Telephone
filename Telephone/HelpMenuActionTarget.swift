//
//  HelpMenuActionTarget.swift
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

import Foundation

final class HelpMenuActionTarget: NSObject {
    private let logFileURL: LogFileURL
    private let homepageURL: URL
    private let faqURL: URL
    private let fileBrowser: FileBrowser
    private let webBrowser: WebBrowser
    private let clipboard: Clipboard
    private let settings: AppSettings

    init(logFileURL: LogFileURL, homepageURL: URL, faqURL: URL, fileBrowser: FileBrowser, webBrowser: WebBrowser, clipboard: Clipboard, settings: AppSettings) {
        self.logFileURL = logFileURL
        self.homepageURL = homepageURL
        self.faqURL = faqURL
        self.fileBrowser = fileBrowser
        self.webBrowser = webBrowser
        self.clipboard = clipboard
        self.settings = settings
    }

    func showLogFile() {
        fileBrowser.showFile(at: logFileURL.urlValue)
    }

    func openHomepage() {
        webBrowser.showPage(at: homepageURL)
    }

    func openFAQ() {
        webBrowser.showPage(at: faqURL)
    }

    func copySettings() {
        clipboard.copy(settings.stringValue)
    }
}
