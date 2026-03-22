//
//  HelpMenuActionTargetTests.swift
//  TelephoneTests
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
import Testing
import UseCasesTestDoubles

@MainActor
struct HelpMenuActionTargetTests {
    @Test func showsLogFileInFileBrowserOnShowLogFile() {
        let url = LogFileURL(locations: ApplicationDataLocationsFake(), filename: "any")
        let browser = FileBrowserSpy()
        let sut = HelpMenuActionTarget(
            logFileURL: url,
            homepageURL: URL(string: "http://homepage.local")!,
            faqURL: URL(string: "http://faq.local")!,
            fileBrowser: browser,
            webBrowser: WebBrowserSpy(),
            clipboard: ClipboardSpy(),
            settings: makeSettingsDummy()
        )

        sut.showLogFile()

        #expect(browser.invokedURL == url.urlValue)
    }

    @Test func opensHomepageInWebBrowserOnOpenHomepage() {
        let url = URL(string: "http://homepage.local")!
        let browser = WebBrowserSpy()
        let sut = HelpMenuActionTarget(
            logFileURL: LogFileURL(locations: ApplicationDataLocationsFake(), filename: "any"),
            homepageURL: url,
            faqURL: URL(string: "http://faq.local")!,
            fileBrowser: FileBrowserSpy(),
            webBrowser: browser,
            clipboard: ClipboardSpy(),
            settings: makeSettingsDummy()
        )

        sut.openHomepage()

        #expect(browser.invokedURL == url)
    }

    @Test func opensFAQInWebBrowserOnOpenFAQ() {
        let url = URL(string: "http://faq.local")!
        let browser = WebBrowserSpy()
        let sut = HelpMenuActionTarget(
            logFileURL: LogFileURL(locations: ApplicationDataLocationsFake(), filename: "any"),
            homepageURL: URL(string: "http://homepage.local")!,
            faqURL: url,
            fileBrowser: FileBrowserSpy(),
            webBrowser: browser,
            clipboard: ClipboardSpy(),
            settings: makeSettingsDummy()
        )

        sut.openFAQ()

        #expect(browser.invokedURL == url)
    }

    @Test func copiesSettingsToClipboardOnCopySettings() {
        let clipboard = ClipboardSpy()
        let settings = SettingsFake()
        settings.set(5, forKey: UserDefaultsKeys.settingsVersion)
        settings.set(true, forKey: UserDefaultsKeys.useICE)
        let appSettings = AppSettings(settings: settings, defaults: [:], accountDefaults: [:])
        let sut = HelpMenuActionTarget(
            logFileURL: LogFileURL(locations: ApplicationDataLocationsFake(), filename: "any"),
            homepageURL: URL(string: "http://homepage.local")!,
            faqURL: URL(string: "http://faq.local")!,
            fileBrowser: FileBrowserSpy(),
            webBrowser: WebBrowserSpy(),
            clipboard: clipboard,
            settings: appSettings
        )

        sut.copySettings()

        #expect(clipboard.invokedText == appSettings.stringValue)
    }
}

@MainActor
private func makeSettingsDummy() -> AppSettings {
    AppSettings(settings: SettingsFake(), defaults: [:], accountDefaults: [:])
}
