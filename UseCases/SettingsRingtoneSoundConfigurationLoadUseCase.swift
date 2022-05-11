//
//  SettingsRingtoneSoundConfigurationLoadUseCase.swift
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

import Domain

public final class SettingsRingtoneSoundConfigurationLoadUseCase {
    private let settings: KeyValueSettings
    private let factory: SoundIOFactory

    public init(settings: KeyValueSettings, factory: SoundIOFactory) {
        self.settings = settings
        self.factory = factory
    }
}

extension SettingsRingtoneSoundConfigurationLoadUseCase: SoundConfigurationLoadUseCase {
    public func execute() throws -> SoundConfiguration {
        return SoundConfiguration(name: try ringtoneSoundName(), deviceUID: try ringtoneAudioDeviceUID())
    }

    private func ringtoneSoundName() throws -> String {
        if let name = settings[SettingsKeys.ringingSound] {
            return name
        } else {
            throw UseCasesError.ringtoneSoundNameNotFoundError
        }
    }

    private func ringtoneAudioDeviceUID() throws -> String {
        return try factory.make().ringtoneOutput.uniqueIdentifier
    }
}
