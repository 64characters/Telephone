//
//  AKSIPUserAgent+UserAgent.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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
    public func audioDevices() throws -> [UserAgentAudioDevice] {
        return try UserAgentAudioDevices().allDevices
    }

    public func selectSoundInputDevice(inputDeviceID: Int, outputDevice outputDeviceID: Int) throws {
        let success = self.setSoundInputDevice(inputDeviceID, soundOutputDevice: outputDeviceID)
        if !success {
            throw TelephoneError.UserAgentSoundIOSelectionError
        }
    }
}
