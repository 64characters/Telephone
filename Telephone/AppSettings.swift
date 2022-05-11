//
//  AppSettings.swift
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
//  but WITHOUT ANY WARRANTY, without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import Foundation
import UseCases

final class AppSettings {
    private let settings: KeyValueSettings
    private let defaults: [String: Any]
    private let accountDefaults: [String: Any]

    var stringValue: String {
        settingsString(settings: settings, defaults: defaults).appending(
            accountSettingsString(settings: settings, accountDefaults: accountDefaults)
        )
    }

    init(settings: KeyValueSettings, defaults: [String: Any], accountDefaults: [String: Any]) {
        self.settings = settings
        self.defaults = defaults
        self.accountDefaults = accountDefaults
    }
}

private func settingsString(settings: KeyValueSettings, defaults: [String: Any]) -> String {
    string(from: dictionary(from: settingsKeys, settings: dictionary(from: settings), defaults: defaults), prefix: "")
}

private func accountSettingsString(settings: KeyValueSettings, accountDefaults: [String: Any]) -> String {
    guard !(settings.array(forKey: UserDefaultsKeys.accounts) ?? []).isEmpty else { return "" }
    return "\n\(UserDefaultsKeys.accounts): \((settings.array(forKey: UserDefaultsKeys.accounts) ?? []).map({ string(from: $0, defaults: accountDefaults) }).joined(separator: " "))"
}

private func string(from dict: [String: Any], prefix: String) -> String {
    return dict.map { key, value in
        let valueString: String
        if let value = value as? Bool {
            valueString = "\(value)"
        } else if let value = value as? Int {
            valueString = "\(value)"
        } else {
            valueString = "\"\(value)\""
        }
        return "\(prefix)\(key): \(valueString)"
    }.sorted().joined(separator: "\n")
}

private func dictionary(from keys: [String: String], settings: [String: Any], defaults: [String: Any]) -> [String: Any] {
    return keys.reduce(into: [:]) { res, kv in
        switch kv.value {
        case "Bool":
            if let current = settings[kv.key] as? Bool, current != defaults[kv.key] as? Bool {
                res[kv.key] = current
            }
        case "Int":
            if let current = settings[kv.key] as? Int, current != defaults[kv.key] as? Int {
                res[kv.key] = current
            }
        default:
            if let current = settings[kv.key] as? String, current != defaults[kv.key] as? String {
                res[kv.key] = current
            }
        }
    }
}

private func dictionary(from settings: KeyValueSettings) -> [String: Any] {
    return settingsKeys.reduce(into: [:]) { res, kv in
        if settings.exists(forKey: kv.key) {
            switch kv.value {
            case "Bool":
                res[kv.key] = settings.bool(forKey: kv.key)
            case "Int":
                res[kv.key] = settings.integer(forKey: kv.key)
            default:
                res[kv.key] = settings[kv.key]
            }
        }
    }
}

private func string(from account: Any, defaults: [String: Any]) -> String {
    guard let account = account as? [String: Any] else { return "" }
    return "{\n" + string(from: dictionary(from: accountKeys, settings: account, defaults: defaults), prefix: "\t") + "\n}"
}

private let settingsKeys = [
    UserDefaultsKeys.autoCloseCallWindow: "Bool",
    UserDefaultsKeys.autoCloseMissedCallWindow: "Bool",
    UserDefaultsKeys.callWaiting: "Bool",
    UserDefaultsKeys.consoleLogLevel: "Int",
    UserDefaultsKeys.formatTelephoneNumbers: "Bool",
    UserDefaultsKeys.keepCallWindowOnTop: "Bool",
    UserDefaultsKeys.lockCodec: "Bool",
    UserDefaultsKeys.logLevel: "Int",
    UserDefaultsKeys.outboundProxyHost: "String",
    UserDefaultsKeys.outboundProxyPort: "Int",
    UserDefaultsKeys.settingsVersion: "Int",
    UserDefaultsKeys.stunServerHost: "String",
    UserDefaultsKeys.stunServerPort: "Int",
    UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits: "Bool",
    UserDefaultsKeys.transportPort: "Int",
    UserDefaultsKeys.useDNSSRV: "Bool",
    UserDefaultsKeys.useG711Only: "Bool",
    UserDefaultsKeys.useICE: "Bool",
    UserDefaultsKeys.useQoS: "Bool",
    UserDefaultsKeys.voiceActivityDetection: "Bool",

    SettingsKeys.soundInput: "String",
    SettingsKeys.soundOutput: "String",
    SettingsKeys.ringtoneOutput: "String",
    SettingsKeys.ringingSound: "String",
    SettingsKeys.pauseITunes: "Bool",
    SettingsKeys.significantPhoneNumberLength: "Int"
]

private let accountKeys = [
    UserDefaultsKeys.accountEnabled: "Bool",
    UserDefaultsKeys.substitutePlusCharacter: "Bool",
    UserDefaultsKeys.plusCharacterSubstitutionString: "String",
    AKSIPAccountKeys.uuid: "String",
    AKSIPAccountKeys.desc: "String",
    AKSIPAccountKeys.fullName: "String",
    AKSIPAccountKeys.sipAddress: "String",
    AKSIPAccountKeys.registrar: "String",
    AKSIPAccountKeys.domain: "String",
    AKSIPAccountKeys.realm: "String",
    AKSIPAccountKeys.username: "String",
    AKSIPAccountKeys.reregistrationTime: "Int",
    AKSIPAccountKeys.useProxy: "Bool",
    AKSIPAccountKeys.proxyHost: "String",
    AKSIPAccountKeys.proxyPort: "Int",
    AKSIPAccountKeys.transport: "String",
    AKSIPAccountKeys.ipVersion: "String",
    AKSIPAccountKeys.updateContactHeader: "Bool",
    AKSIPAccountKeys.updateViaHeader: "Bool",
    AKSIPAccountKeys.updateSDP: "Bool",
]
