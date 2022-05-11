//
//  DefaultAppSettings.swift
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
import UseCases

final class DefaultAppSettings: NSObject {
    let defaults: [String: Any]

    private let settings: KeyValueSettings

    init(settings: KeyValueSettings, localization: String) {
        self.settings = settings
        self.defaults = makeDefaults(for: localization)
    }

    @objc(registerDefaults)
    func register() {
        settings.register(defaults: defaults)
    }

    static let accountDefaults: [String: Any] = [
        UserDefaultsKeys.substitutePlusCharacter: false,
        UserDefaultsKeys.plusCharacterSubstitutionString: "00",
        AKSIPAccountKeys.desc: "",
        AKSIPAccountKeys.sipAddress: "",
        AKSIPAccountKeys.registrar: "",
        AKSIPAccountKeys.realm: "*",
        AKSIPAccountKeys.reregistrationTime: 0,
        AKSIPAccountKeys.useProxy: false,
        AKSIPAccountKeys.proxyHost: "",
        AKSIPAccountKeys.proxyPort: 0,
        AKSIPAccountKeys.transport: AKSIPAccountKeys.transportUDP,
        AKSIPAccountKeys.ipVersion: AKSIPAccountKeys.ipVersion4,
        AKSIPAccountKeys.updateContactHeader: true,
        AKSIPAccountKeys.updateViaHeader: true,
        AKSIPAccountKeys.updateSDP: true,
    ]
}

private func makeDefaults(for localization: String) -> [String: Any] {
    var result: [String: Any] = [
        UserDefaultsKeys.autoCloseCallWindow: true,
        UserDefaultsKeys.autoCloseMissedCallWindow: true,
        UserDefaultsKeys.callWaiting: true,
        UserDefaultsKeys.consoleLogLevel: 0,
        UserDefaultsKeys.formatTelephoneNumbers: true,
        UserDefaultsKeys.keepCallWindowOnTop: true,
        UserDefaultsKeys.lockCodec: false,
        UserDefaultsKeys.logLevel: 3,
        UserDefaultsKeys.outboundProxyHost: "",
        UserDefaultsKeys.outboundProxyPort: 0,
        UserDefaultsKeys.stunServerHost: "",
        UserDefaultsKeys.stunServerPort: 0,
        UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits: false,
        UserDefaultsKeys.transportPort: 0,
        UserDefaultsKeys.useDNSSRV: false,
        UserDefaultsKeys.useG711Only: false,
        UserDefaultsKeys.useICE: false,
        UserDefaultsKeys.useQoS: true,
        UserDefaultsKeys.voiceActivityDetection: false,

        SettingsKeys.ringingSound: "Purr",
        SettingsKeys.pauseITunes: true,
        SettingsKeys.significantPhoneNumberLength: 9,
    ]
    if localization == "de" {
        result[UserDefaultsKeys.formatTelephoneNumbers] = false
    }
    if localization == "ru" {
        result[UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits] = true
    }
    return result
}
