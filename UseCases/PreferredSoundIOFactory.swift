//
//  PreferredSoundIOFactory.swift
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

public final class PreferredSoundIOFactory {
    private let devicesFactory: SystemAudioDevicesFactory
    private let defaultIOFactory: SystemSoundIOFactory
    private let settings: KeyValueSettings

    public init(devicesFactory: SystemAudioDevicesFactory, defaultIOFactory: SystemSoundIOFactory, settings: KeyValueSettings) {
        self.devicesFactory = devicesFactory
        self.defaultIOFactory = defaultIOFactory
        self.settings = settings
    }
}

extension PreferredSoundIOFactory: SoundIOFactory {
    public func make() throws -> SoundIO {
        return PreferredSoundIO(
            devices: try devicesFactory.make(), settings: settings, defaultIO: try defaultIOFactory.make()
        )
    }
}
