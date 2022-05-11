//
//  UserDefaultsKeys.swift
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

@objcMembers
class UserDefaultsKeys: NSObject {
    static let accounts = "Accounts"
    static let stunServerHost = "STUNServerHost"
    static let stunServerPort = "STUNServerPort"
    static let logLevel = "LogLevel"
    static let consoleLogLevel = "ConsoleLogLevel"
    static let voiceActivityDetection = "VoiceActivityDetection"
    static let transportPort = "TransportPort"
    static let formatTelephoneNumbers = "FormatTelephoneNumbers"
    static let telephoneNumberFormatterSplitsLastFourDigits = "TelephoneNumberFormatterSplitsLastFourDigits"
    static let outboundProxyHost = "OutboundProxyHost"
    static let outboundProxyPort = "OutboundProxyPort"
    static let useICE = "UseICE"
    static let useDNSSRV = "UseDNSSRV"
    static let useQoS = "UseQoS"
    static let autoCloseCallWindow = "AutoCloseCallWindow"
    static let autoCloseMissedCallWindow = "AutoCloseMissedCallWindow"
    static let keepCallWindowOnTop = "KeepCallWindowOnTop"
    static let callWaiting = "CallWaiting"
    static let useG711Only = "UseG711Only"
    static let lockCodec = "LockCodec"
    static let settingsVersion = "SettingsVersion"

    static let accountEnabled = "AccountEnabled"
    static let substitutePlusCharacter = "SubstitutePlusCharacter"
    static let plusCharacterSubstitutionString = "PlusCharacterSubstitutionString"

    static let ringingSound = SettingsKeys.ringingSound
    static let significantPhoneNumberLength = SettingsKeys.significantPhoneNumberLength
}
