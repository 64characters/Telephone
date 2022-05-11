//
//  CoreAudioDefaultSystemSoundIOFactory.swift
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

import CoreAudio
import Domain
import UseCases

final class CoreAudioDefaultSystemSoundIOFactory {
    private let defaultIO: CoreAudioDefaultIO

    init(defaultIO: CoreAudioDefaultIO) {
        self.defaultIO = defaultIO
    }
}

extension CoreAudioDefaultSystemSoundIOFactory: SystemSoundIOFactory {
    func make() throws -> SystemSoundIO {
        return SimpleSystemSoundIO(
            input: try SimpleSystemAudioDevice(deviceID: try defaultIO.inputID()),
            output: try SimpleSystemAudioDevice(deviceID: try defaultIO.outputID())
        )
    }
}
