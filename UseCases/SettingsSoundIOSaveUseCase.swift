//
//  SettingsSoundIOSaveUseCase.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

import Domain

public final class SettingsSoundIOSaveUseCase {
    private let inputName: String
    private let outputName: String
    private let ringtoneOutputName: String
    private let settings: KeyValueSettings

    public init(inputName: String, outputName: String, ringtoneOutputName: String, settings: KeyValueSettings) {
        self.inputName = inputName
        self.outputName = outputName
        self.ringtoneOutputName = ringtoneOutputName
        self.settings = settings
    }
}

extension SettingsSoundIOSaveUseCase: UseCase {
    public func execute() {
        saveInputIfNeeded()
        saveOutputIfNeeded()
        saveRingtoneOutputIfNeeded()
    }

    private func saveInputIfNeeded() {
        if !inputName.isEmpty {
            settings[SettingsKeys.soundInput] = inputName
        }
    }

    private func saveOutputIfNeeded() {
        if !outputName.isEmpty {
            settings[SettingsKeys.soundOutput] = outputName
        }
    }

    private func saveRingtoneOutputIfNeeded() {
        if !ringtoneOutputName.isEmpty {
            settings[SettingsKeys.ringtoneOutput] = ringtoneOutputName
        }
    }
}
