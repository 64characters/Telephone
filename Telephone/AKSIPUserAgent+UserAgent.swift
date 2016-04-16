//
//  AKSIPUserAgent+UserAgent.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

import UseCases

extension AKSIPUserAgent: UserAgent {
    public var hasActiveCalls: Bool {
        return started && activeCallsCount > 0
    }

    public func audioDevices() throws -> [UserAgentAudioDevice] {
        if started {
            return try UserAgentAudioDevices().all
        } else {
            throw UserAgentError.UserAgentNotStarted
        }
    }

    public func selectSoundIODeviceIDs(input input: Int, output: Int) throws {
        let success = self.setSoundInputDevice(input, soundOutputDevice: output)
        if !success {
            throw UserAgentError.SoundIOSelectionError
        }
    }
}
