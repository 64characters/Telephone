//
//  UserAgentSpy.swift
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

import Foundation
import UseCases

public final class UserAgentSpy: NSObject {
    public var isStarted = false
    public fileprivate(set) var hasActiveCalls = false

    public fileprivate(set) var didCallAudioDevices = false
    public var audioDevicesResult = [UserAgentAudioDevice]()

    public fileprivate(set) var didCallUpdateAudioDevices = false
    public fileprivate(set) var soundIOSelectionCallCount = 0
    public var didSelectSoundIO: Bool { return soundIOSelectionCallCount > 0 }

    public fileprivate(set) var invokedInputDeviceID: Int?
    public fileprivate(set) var invokedOutputDeviceID: Int?

    public func simulateActiveCalls() {
        hasActiveCalls = true
    }
}

extension UserAgentSpy: UserAgent {
    public func audioDevices() throws -> [UserAgentAudioDevice] {
        didCallAudioDevices = true
        return audioDevicesResult
    }

    public func updateAudioDevices() {
        didCallUpdateAudioDevices = true
    }

    public func selectSoundIODeviceIDs(input: Int, output: Int) throws {
        soundIOSelectionCallCount += 1
        invokedInputDeviceID = input
        invokedOutputDeviceID = output
    }
}
