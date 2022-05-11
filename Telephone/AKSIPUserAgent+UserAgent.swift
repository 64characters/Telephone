//
//  AKSIPUserAgent+UserAgent.swift
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
import UseCases

extension AKSIPUserAgent: UserAgent {
    public func audioDevices() throws -> [UserAgentAudioDevice] {
        if isStarted {
            return try UserAgentAudioDevices().all
        } else {
            throw UserAgentError.userAgentNotStarted
        }
    }

    public func selectSoundIODeviceIDs(input: Int, output: Int) throws {
        let success = self.setSoundInputDevice(input, soundOutputDevice: output)
        if !success {
            throw UserAgentError.soundIOSelectionError
        }
    }
}
