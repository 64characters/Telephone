//
//  SettingsSoundIOSaveUseCase.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

public final class SettingsSoundIOSaveUseCase {
    fileprivate let soundIO: PresentationSoundIO
    fileprivate let settings: KeyValueSettings

    public init(soundIO: PresentationSoundIO, settings: KeyValueSettings) {
        self.soundIO = soundIO
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
        if !soundIO.input.isEmpty {
            settings[SettingsKeys.soundInput] = soundIO.input
        }
    }

    private func saveOutputIfNeeded() {
        if !soundIO.output.isEmpty {
            settings[SettingsKeys.soundOutput] = soundIO.output
        }
    }

    private func saveRingtoneOutputIfNeeded() {
        if !soundIO.ringtoneOutput.isEmpty {
            settings[SettingsKeys.ringtoneOutput] = soundIO.ringtoneOutput
        }
    }
}
